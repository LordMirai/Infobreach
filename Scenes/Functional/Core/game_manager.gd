extends Node2D

@export var current_score: int = 0
@export var max_score: int = 0
@export var rating: int = 0 # 0-3 "Masks" (stars)

var game_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize():
	calculate_max_score()



func calculate_max_score():
	# get all hackable devices in the scene and sum their score rewards
	var hackable_devices = get_tree().current_scene.get_nodes_in_group("hackable_devices")



func level_fail():
	print("Level Failed")
	# make a popup that says "Level Failed" and a button to restart the level
	# for now, just restart the level immediately
	get_tree().reload_current_scene()