extends "res://Scenes/Functional/Interactables/Base/interactable.gd"

const Player = preload("res://Scenes/Functional/Player/player.gd")

var door_open: bool = false


@export var active_tex: Texture2D = preload("res://Scenes/Functional/Interactables/Doors/vert door.piskel")
@export var disabled_tex: Texture2D = preload("res://Scenes/Functional/Interactables/Doors/door disabled.png")


func _toggle_door():
	door_open = not door_open

	$"Body Blocker".disabled = door_open
	$Sprite2D.texture = active_tex if not door_open else disabled_tex

	$AudSource.play()



func sub_interact():
	if not _colliding_with_player():
		_toggle_door()



func _colliding_with_player() -> bool:
	# check if 2 rectangles overlap



	return false
