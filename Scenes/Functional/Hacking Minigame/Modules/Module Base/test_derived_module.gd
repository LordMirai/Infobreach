extends "res://Scenes/Functional/Hacking Minigame/Modules/Module Base/base_module.gd"


func sub_init():
	print("Derived module " + module_name + " initialized with difficulty " + str(difficulty))
	# Additional initialization logic specific to this derived module
	# texture expand to container parent
	$TextureRect.expand = true
