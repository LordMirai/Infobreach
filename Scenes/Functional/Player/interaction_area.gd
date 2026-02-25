extends Area2D


"""
Player Interaction Area Script
Manages interactables in range
if ent in range, check if interactable and set as active
if player presses interact, call interact on active interactable
if player leaves range, clear reference

"""
#TODO: Bind to GUI to show interaction prompt when in range

const Interactable = preload("res://Scenes/Functional/Interactables/Base/interactable.gd")

# Variable to hold the reference to the active interactable
var active_interactable: Interactable = null


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		print("Entered interaction area of: " + str(area.get_parent().interactable_name))
		active_interactable = area.get_parent() as Interactable

func _on_area_exited(area: Area2D) -> void:
	if active_interactable == area.get_parent():
		print("Exited interaction area of: " + str(area.get_parent().interactable_name))
		active_interactable = null


func _input(event):
	if event.is_action_pressed("ui_accept") and active_interactable != null:
		print("action request received")
		active_interactable._on_interact()
