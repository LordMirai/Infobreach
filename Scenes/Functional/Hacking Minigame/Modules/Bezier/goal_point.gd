extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_intersected: bool:
	set(intersected):
		is_intersected = intersected
		if is_intersected:
			sprite.modulate = Color(1, 0, 0, 1)
		else:
			sprite.modulate = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func detect_input(point: Vector2) -> bool:
	var parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	parameters.from = point
	parameters.to = point
	parameters.hit_from_inside = true
	parameters.collide_with_areas = true
	#parameters.collision_mask = collision.collision_mask
	#parameters.collision_mask = self.collision_mask
	# get all area2d colliders
	var objects_touched: Dictionary = get_world_2d().direct_space_state.intersect_ray(parameters)
	#print(objects_touched)
	return objects_touched and objects_touched.collider == self
		##is_intersected = true
		#return true
	##is_intersected = false
	#return false
