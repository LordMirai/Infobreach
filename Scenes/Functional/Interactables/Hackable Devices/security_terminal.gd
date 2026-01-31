extends "res://Scenes/Functional/Interactables/Hackable Devices/base_device.gd"

@export var linked_drone: CharacterBody2D

func _ready() -> void:
	super._ready()
	device_name = "Drone Control Node"
	hack_difficulty = 3
	
func on_hack_successful():
	super.on_hack_successful()
	
	if linked_drone and linked_drone.has_method("disable_drone"):
		print("Terminal Command: Disabling Drone.")
		linked_drone.disable_drone()
	else:
		print("Hack succesful, but no drone is linked!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
