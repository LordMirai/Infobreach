extends "res://Scenes/Functional/Hacking Minigame/Modules/Module Base/base_module.gd"


var input: int = 1000
var output: int = 2000 # whatever it is, do not go past 4095
var method: String = "Addition" # or "XOR"
var mask: String = ""

var see_as_binary: bool = false

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

	if method == "Addition" and output <= input:
		var temp = input
		input = output
		output = temp

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
	if method == "Addition":
		return input + _get_mask()[1]
	elif method == "XOR":
		return input ^ _get_mask()[1]

func _update_labels():
	print("update label called?")
	var msk = _get_mask()
	print("Mask: ", msk[0], " Value: ", msk[1])

	var _tmp = _get_temp()

	# print("Button index %d pressed, state %s, value %d" % [index, str(toggled_on), value])

	var _inp = String.num_int64(input, 2) if see_as_binary else input
	var _outp = String.num_int64(output, 2) if see_as_binary else output
	var _temp = String.num_int64(_tmp, 2) if see_as_binary else _tmp

	$Container/Background/Input.text = "Input: " + str(_inp)
	$Container/Background/Symbol.text = symbol_table[method]
	$Container/Background/Output.text = "Output: " + str(_outp)
	$Container/Background/Mask.text = "Mask: " + msk[0] + "  " + str(msk[1])
	$Container/Background/Out_Temp.text = "Temp: " + str(_temp)

	if _tmp == output:
		complete_module()

func _on_binary_view_btn_pressed() -> void:
	see_as_binary = !see_as_binary
	_update_labels()
