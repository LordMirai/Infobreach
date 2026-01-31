extends "res://Scenes/Functional/Interactables/Base/interactable.gd"

# preload minigame
var HackingMinigame : PackedScene = preload("res://Scenes/Functional/Hacking Minigame/HackingMinigame.tscn")

@export var hackable: bool = true
@export var hacked: bool = false
@export var device_name: String = "Base Device"
@export var hack_difficulty: int = 1  # 0 (no-hack), 1 (easy) to 3 (hard)

@export var default_texture: Texture2D
@export var hacked_texture: Texture2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = default_texture

	add_user_signal("device_hacked", [device_name])
	add_user_signal("device_hack_failed", [device_name])


func sub_interact():
	if hackable and not hacked:
		print("Starting hack on device: " + device_name)
		
		var hacking_ui = HackingMinigame.instantiate()
		get_tree().current_scene.add_child(hacking_ui)

		hacking_ui.initialize_minigame(self)

# prepare hack successful/failed signals
func on_hack_successful():
	hacked = true
	print("Device " + device_name + " hacked successfully.")
	$Sprite2D.texture = hacked_texture
	emit_signal("device_hacked", device_name)
	# Additional logic for successful hack


func on_hack_failed():
	print("Hack failed on device: " + device_name)
	emit_signal("device_hack_failed", device_name)
