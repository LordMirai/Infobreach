extends Control

# load minigame
const HackingMinigameModule = preload("res://Scenes/Functional/Hacking Minigame/hacking_minigame.gd")

var parent_minigame: HackingMinigameModule = null
var minigame_frame: PanelContainer = null

@export var module_name: String = "Base Module"
@export var difficulty: int = 1
@export var hack_enabled: bool = false # cheaty flag to enable hack complete button
@export var self_reset_on_fail: bool = false # if False, Module manager will destroy the module on fail and generate another. set to True if you reset it yourself

const DEBUG: bool = true

signal module_completed(module_name)
signal module_failed(module_name)


func _ready() -> void:
	if parent_minigame != null:
		initialize_module(parent_minigame)


func fail_module():
	print("Module " + module_name + " failed.")
	emit_signal("module_failed", module_name)
	

func complete_module():
	print("Module " + module_name + " completed.")
	emit_signal("module_completed", module_name)

func _debug_labels():
	if DEBUG:
		$Container/Background/NameLabel.text = module_name
		$Container/Background/DifficultyLabel.text = "Difficulty: " + str(difficulty)
	else:
		$Container/Background/NameLabel.text = ""
		$Container/Background/DifficultyLabel.text = ""
		
		$HackComplete.queue_free()

func initialize_module(minigame):
	parent_minigame = minigame
	_debug_labels()

	sub_init()


func reset_module():
	# pass
	initialize_module(parent_minigame) # Comment this out if you don't want to re-initialize on reset


func sub_init():
	pass  # To be overridden in derived classes for specific initialization


func _on_hack_complete_pressed() -> void:
	complete_module()
