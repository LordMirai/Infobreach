extends CharacterBody2D

@export var movement_speed: float = 150.0
@export var patrol_points: Array[Node2D] # Drag Marker2D nodes here
@export var wait_time: float = 1.0

@onready var vision_cone: Area2D = $VisionCone
@onready var raycast: RayCast2D = $RayCast2D

var current_point_index: int = 0
var is_waiting: bool = false
var is_active: bool = true

func _ready() -> void:
	raycast.add_exception(self)

func _physics_process(_delta: float) -> void:
	if not is_active:
		return
		
	_patrol()
	_scan_for_player()

func _patrol() -> void:
	if patrol_points.is_empty() or is_waiting:
		return

	var target = patrol_points[current_point_index]
	if not target: return

	var target_pos = target.global_position
	var distance = global_position.distance_to(target_pos)

	if distance < 5.0:
		_start_wait()
	else:
		var direction = (target_pos - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()
		
		rotation = lerp_angle(rotation, direction.angle(), 0.1)

func _start_wait() -> void:
	is_waiting = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(wait_time).timeout
	current_point_index = (current_point_index + 1) % patrol_points.size()
	is_waiting = false

func _scan_for_player() -> void:
	var bodies = vision_cone.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			_check_line_of_sight(body)

func _check_line_of_sight(target: Node2D) -> void:
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		# Check if we hit the player (and not a wall)
		if raycast.get_collider() == target:
			print("GAME OVER: Drone caught you!")
			# logic to restart level goes here

# Called by the Terminal
func disable_drone() -> void:
	print("Drone Powering Down...")
	is_active = false
	velocity = Vector2.ZERO
	modulate = Color(0.5, 0.5, 0.5) # Darken sprite to show it's off
