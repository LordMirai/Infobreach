extends Control

const HackableDevice = preload("res://Scenes/Functional/Interactables/Hackable Devices/base_device.gd")

var parent_entity: HackableDevice = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(position)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initialize_minigame(hackable : HackableDevice):
	parent_entity = hackable

func _on_mimic_pressed() -> void:
	parent_entity.on_hack_successful()
	queue_free()
