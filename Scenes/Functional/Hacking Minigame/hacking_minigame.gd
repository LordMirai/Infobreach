extends Control

const HackableDevice = preload("res://Scenes/Functional/Interactables/Hackable Devices/base_device.gd")

var parent_entity: HackableDevice = null

@export var difficulty: int = 1
@export var module_count: int = 1
var modules_completed: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initialize_minigame(hackable : HackableDevice):
	parent_entity = hackable

	# Pass the parent_device reference to the hacking UI
	if $HackingUI:
		$HackingUI.parent_device = parent_entity

func _on_mimic_pressed() -> void:
	parent_entity.on_hack_successful()
	queue_free()





#! SECTION: Module Loader

const BaseModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/BaseModule.tscn")
const TestModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/test_derived_module.tscn")

var module_pool = [
	{
		scene = TestModuleScene,
		script = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/test_derived_module.gd")
	},
]

func select_module():
	var module_index = randi() % module_pool.size()
	return module_pool[module_index]

func pull_next_module():
	var module_data = select_module()
	var module_instance = module_data.scene.instantiate()
	module_instance.set_script(module_data.script)
	module_instance.parent_minigame = self

	$Container/ModuleFrame.add_child(module_instance)
	
	module_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	print("Container origin: " + str($Container/ModuleFrame.position) + "; module position: " + str(module_instance.position))

	module_instance.initialize_module(self)
	return module_instance


func _on_gen_module_pressed() -> void:
	var module = pull_next_module()
	print("Generated module: " + str(module.module_name))
