extends "res://Scenes/Functional/Hacking Minigame/Modules/Module Base/base_module.gd"


var input: int = 1000
var output: int = 2000 # whatever it is, do not go past 4095
var method: String = "Addition" # or "XOR"
var mask: String = ""

var symbol_table = {
	"Addition": "+",
	"XOR": "⊕"
}

func sub_init():
	input = randi_range(0, 4096)
	output = randi_range(100, 4096)
	method = symbol_table.keys()[randi() % symbol_table.size()]
	_update_labels()


func _update_labels():
	$Container/Background/Input.text = "Input: " + str(input)
	$Container/Background/Symbol.text = symbol_table[method]
	$Container/Background/Output.text = "Output: " + str(output)
	$Container/Background/Mask.text = "Mask: " + str(mask)
