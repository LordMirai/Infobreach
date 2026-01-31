extends CharacterBody2D

@export var movement_speed: float = 150.0
@export var patrol_points: Array[Node2D] # Drag Marker2D nodes here
@export var wait_time: float = 1.0

@export var detection_speed: float = 60.0
@export var decay_speed: float = 20.0
var detection_level: float = 0.0

@onready var vision_cone: Area2D = $VisionCone
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision_poly: CollisionPolygon2D = $VisionCone/CollisionPolygon2D

var current_point_index: int = 0
var is_waiting: bool = false
var is_active: bool = true
var player_in_sight: bool = false

func _ready() -> void:
	raycast.add_exception(self)

func _process(delta: float) -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not is_active:
		return
		
	_patrol_logic()
	_handle_detection(delta)

func _patrol_logic() -> void:
	if patrol_points.is_empty() or is_waiting:
		return
	
	var target = patrol_points[current_point_index]
	if not target: return
	
	var direction = (target.global_position - global_position).normalized()
	if global_position.distance_to(target.global_position) < 5.0:
		_start_wait()
	else:
		velocity = direction * movement_speed
		move_and_slide()
		rotation = lerp_angle(rotation, direction.angle(), 0.1)

func _start_wait() -> void:
	is_waiting = true
	velocity = Vector2.ZERO
	
	var tween = create_tween()
	var current_rot = rotation
	
	tween.tween_property(self, "rotation", current_rot - deg_to_rad(45), wait_time)
	tween.tween_property(self, "rotation", current_rot + deg_to_rad(45), wait_time)
	tween.tween_property(self, "rotation", current_rot + deg_to_rad(45), wait_time)	
	
	await  tween.finished
	
	current_point_index = (current_point_index + 1) % patrol_points.size()
	is_waiting = false

func _handle_detection(delta:float) -> void:
	player_in_sight = false
	var bodies = vision_cone.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Player"):
			raycast.target_position = to_local(body.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding() and raycast.get_collider() == body:
				player_in_sight = true
				break
				
	if player_in_sight:
		detection_level += detection_speed * delta
	else:
		detection_level -= decay_speed * delta
		
		detection_level = clamp(detection_level, 0, 100)
		
		if detection_level >= 100:
			trigger_game_over()
			
func trigger_game_over() -> void:
	print("GAME OVER: Maximum Detection Reached")
	set_physics_process(false)
	#add game over logic here
	
# Called by the Terminal
func disable_drone() -> void:
	is_active = false
	detection_level = 0
	velocity = Vector2.ZERO
	modulate = Color(0.5, 0.5, 0.5) # Darken sprite to show it's off
	print("Drone disabled")
	
func _draw() -> void:
	if not collision_poly: return
	
	var cone_color = Color(0, 1, 0, 0.2)
	if detection_level > 0:
		cone_color = Color(0, 1, 0, 0.2).lerp(Color(1, 0, 0, 0.4), detection_level / 100.0)
	
	draw_polygon(collision_poly.polygon, [cone_color])
	
	if is_active:
		var time = Time.get_ticks_msec() / 1000.0
		var sweep_angle = sin(time*2.0) * 0.5
		var scan_length = 600
		var end_point = Vector2(cos(sweep_angle), sin(sweep_angle)) * scan_length
		
		draw_line(Vector2.ZERO, end_point, Color(0, 1, 0, 0.7), 2.0)
		
	if detection_level > 0:
		var bar_width = 60
		var bar_height = 6
		var bar_pos = Vector2(-bar_width/2, -50)
		
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.BLACK)
		
		var fill_width = (detection_level / 100.0) * bar_width
		draw_rect(Rect2(bar_pos, Vector2(fill_width, bar_height)), Color(1, 0.5, 0))
