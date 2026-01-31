extends Control

const Player = preload("res://Scenes/Functional/Player/player.gd")

var player: Player = null


func _ready() -> void:
	get_parent().position = get_tree().root.size / 2 # center screen
	player = get_tree().current_scene.get_node("Player") as Player
	if not player:
		push_error("Player node not found in the current scene.")
		return
	player.movement_enabled = false




func _on_close_button_pressed() -> void:
	get_parent().queue_free() # close parent


func _on_minigame_closed() -> void:
	player.movement_enabled = true
