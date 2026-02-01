extends "res://Scenes/Functional/Hacking Minigame/Modules/Module Base/base_module.gd"


var input: int = 1000
var output: int = 2000 # whatever it is, do not go past 4095
var method: String = "Addition" # or "XOR"
var mask: String = ""

var symbol_table = {
	"Addition": "+",
	"XOR": "⊕"
}

func _ready():
	for button in $Container/Background/ButtonPanel.get_children():
		button.connect("binary_toggled", _update_labels)


func sub_init():
	input = randi_range(0, 4096)
	output = randi_range(100, 4096)
	method = symbol_table.keys()[randi() % symbol_table.size()]
	_update_labels()

func _get_mask() -> Array:
	var button_panel = $Container/Background/ButtonPanel

	var mask_str = ""
	var mask_value = 0
	for button in button_panel.get_children():
		var digit = "1" if button.button_pressed else "0"
		mask_str = digit + mask_str # prepend to get correct order
		mask_value += button.value
	mask_str = "0b" + mask_str
	return [mask_str, mask_value]

func _get_temp():
	pass

func _update_labels():
	print("update label called?")
	var msk = _get_mask()
	print("Mask: ", msk[0], " Value: ", msk[1])
	$Container/Background/Input.text = "Input: " + str(input)
	$Container/Background/Symbol.text = symbol_table[method]
	$Container/Background/Output.text = "Output: " + str(output)
	$Container/Background/Mask.text = "Mask: " + msk[0] + "  " + str(msk[1])
	$Container/Background/Out_Temp.text = "Temp: " + str(_get_temp())
