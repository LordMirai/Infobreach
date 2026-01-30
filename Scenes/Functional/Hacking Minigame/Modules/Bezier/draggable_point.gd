extends Area2D

var is_dragging: bool = false
var click_position: Vector2 = Vector2.ZERO
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - click_position


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		parameters.position = event.position
		parameters.collide_with_areas = true
		# get all area2d colliders
		var objects_clicked: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(parameters)
		var colliders = objects_clicked.map(
			func(dict):
				return dict.collider
		)
		colliders.sort_custom(
			func(c1, c2):
				return c1.z_index < c2.z_index
		)
		# we're only clicking on the topmost collider
		if colliders[-1] == self:
			is_dragging = true
			click_position = get_local_mouse_position()
		
func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		is_dragging = false
