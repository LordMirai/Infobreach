extends Area2D

var is_draggable: bool = true
var is_dragging: bool = false
var click_position: Vector2 = Vector2.ZERO
var top_left: Vector2 = Vector2.ZERO
var bounds: Vector2 = Vector2.ZERO
@onready var collision: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging and is_draggable:
		global_position = get_global_mouse_position() - click_position
		# make sure the draggable point doesn't go out of module bounds
		if global_position.x < top_left.x:
			global_position.x = top_left.x
		elif global_position.x > top_left.x + bounds.x:
			global_position.x = top_left.x + bounds.x
		if global_position.y < top_left.y:
			global_position.y = top_left.y
		elif global_position.y > top_left.y + bounds.y:
			global_position.y = top_left.y + bounds.y


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
		parameters.from = event.position
		parameters.to = event.position
		parameters.hit_from_inside = true
		#parameters.collision_mask = collision.collision_mask
		print("Clicked on ", event.position, " At" , position)
		parameters.collide_with_areas = true
		# get all area2d colliders
		var objects_clicked: Dictionary = get_world_2d().direct_space_state.intersect_ray(parameters)
		print(objects_clicked)
		#var colliders = objects_clicked.map(
			#func(dict):
				#return dict.collider
		#)
		#print(colliders)
		#colliders.sort_custom(
			#func(c1, c2):
				#return c1.z_index < c2.z_index
		#)
		# we're only clicking on the topmost collider
		#print(colliders)
		if objects_clicked and objects_clicked.collider == self:
			is_dragging = true
			click_position = get_local_mouse_position()
		
func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		is_dragging = false
