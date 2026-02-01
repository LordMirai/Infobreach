extends Control

const HackableDevice = preload("res://Scenes/Functional/Interactables/Hackable Devices/base_device.gd")

var parent_entity: HackableDevice = null

@export var difficulty: int = 1
@export var module_count: int = 3
var modules_completed: int = 0

var fail_count: int = 0
var fail_limit: int = 3 # module fail limit (count==limit -> minigame fail)


func _update_labels():
	$CanvasLayer/Container/Device.text = parent_entity.device_name
	$CanvasLayer/Container/Difficulty.text = "Difficulty: " + str(difficulty)
	$CanvasLayer/Container/Completion.text = "Modules Completed: " + str(modules_completed) + " / " + str(module_count)
	$CanvasLayer/Container/Failures.text = "Failures: " + str(fail_count) + " / " + str(fail_limit)

func initialize_minigame(hackable : HackableDevice):
	parent_entity = hackable

	_update_labels()

	# Pass the parent_device reference to the hacking UI
	if $CanvasLayer/Container:
		$CanvasLayer/Container.parent_device = parent_entity
func _on_mimic_pressed() -> void:
	parent_entity.on_hack_successful()
	queue_free()





#! SECTION: Module Loader

const BaseModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/BaseModule.tscn")
const TestModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/test_derived_module.tscn")

const KeywordModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Keyword/KeywordModule.tscn")
const BezierModuleScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Bezier/bezier.tscn")
const BinaryMaskingScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/BinaryMasking/binary_masking.tscn")
const FrequencyModulationScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/FrequencyModulation/FrequencyModulationModule.tscn")

var module_pool = [
	{
		scene = TestModuleScene,
		script = preload("res://Scenes/Functional/Hacking Minigame/Modules/Module Base/test_derived_module.gd")
	},
	# {
	# 	scene = KeywordModuleScene,
	# 	script = preload("res://Scenes/Functional/Modules/KeywordMatching/KeywordMatchingModule.cs")
	# },
	{
		scene = BezierModuleScene,
		script = preload("res://Scenes/Functional/Hacking Minigame/Modules/Bezier/bezier.gd")
	},
	{
		scene = BinaryMaskingScene,
		script = preload("res://Scenes/Functional/Hacking Minigame/Modules/BinaryMasking/binary_masking.gd")
	},
	{
		scene = FrequencyModulationScene,
		script = preload("res://Scenes/Functional/Modules/FrequencyModulation/FrequencyModulationMinigame.cs")
	}
]


var current_module = null


func select_module():
	var module_index = randi() % module_pool.size()
	return module_pool[module_index]

func pull_next_module():
	var module_data = select_module()
	var module_instance = module_data.scene.instantiate()
	module_instance.set_script(module_data.script)
	module_instance.parent_minigame = self
	module_instance.minigame_frame = get_node("CanvasLayer/Container/ModuleFrame")

	$CanvasLayer/Container/ModuleFrame.add_child(module_instance)
	current_module = module_instance
	
	module_instance.set_anchors_preset(Control.PRESET_FULL_RECT)

	module_instance.initialize_module(self)
	module_instance.connect("module_completed", Callable(self, "on_module_completed"))

	return module_instance


func _on_gen_module_pressed() -> void:
	pull_next_module()



func on_module_completed(module_name: String) -> void:
	modules_completed += 1
	_update_labels()
	print("Module completed: " + module_name)

	if modules_completed >= module_count:
		print("All modules completed! Hacking successful.")
		parent_entity.on_hack_successful()
		queue_free()
	else:
		if current_module:
			current_module.queue_free()
		pull_next_module()


func on_module_failed(module_name: String) -> void:
	fail_count += 1
	_update_labels()
	print("Module failed: " + module_name)
	if fail_count >= fail_limit:
		print("Fail limit reached! Hacking failed.")
		parent_entity.on_hack_failed()
		queue_free()
	else:
		if current_module:
			current_module.reset_module()
