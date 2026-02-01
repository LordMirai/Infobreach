extends Control

const Player = preload("res://Scenes/Functional/Player/player.gd")
const HackableDevice = preload("res://Scenes/Functional/Interactables/Hackable Devices/base_device.gd")

var player: Player = null
var active_hacking_ui: Control = null # Static variable to track the active hacking UI
var parent_device: HackableDevice = null # Reference to the parent device


func _ready() -> void:
	# Ensure the active hacking UI is unique
	if active_hacking_ui and active_hacking_ui != self:
		active_hacking_ui.queue_free()

	active_hacking_ui = self

	get_parent().position = get_tree().root.size / 2 # center screen
	player = get_tree().current_scene.get_node("Player") as Player
	if player:
		player.movement_enabled = false




func _on_close_button_pressed() -> void:
	
	parent_device.on_hack_failed()
	get_parent().queue_free() # close parent
	
	# Clear the active hacking UI reference
	if active_hacking_ui == self:
		active_hacking_ui = null
	


func _on_minigame_closed() -> void:

	if player:
		player.movement_enabled = true

	if parent_device:
		parent_device.on_hack_failed()
		parent_device.hacking_ui_instance = null

	# Clear the active hacking UI reference
	if active_hacking_ui == self:
		active_hacking_ui = null
