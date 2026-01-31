extends Control

@onready var start_label = $StartPrompt
@onready var os_icon = $OSIcon
@onready var prompt_hbox = $PromptHbox
@onready var start_prompt = $PromptHbox/Hostname
@onready var command_input = $PromptHbox/CommandInput
@onready var menu_text = $PromptHbox/Menu

var is_booted = false

func _input(event: InputEvent) -> void:
	if not is_booted and event is InputEventKey and event.is_pressed():
		boot_system()

func boot_system():
	is_booted = true
	start_label.visible = false
	
	var tween = create_tween()

	tween.tween_property(os_icon, "modulate:a", 0.0, 0.75)	
	
	tween.tween_interval(0.8)

	tween.tween_callback(func():
		os_icon.visible = false
		prompt_hbox.visible = true
		command_input.text = ""
		command_input.editable = false
	)

	var cmd_text = "./infiltrate.sh"
	for i in range(cmd_text.length()):
		tween.tween_callback(func(): command_input.text += cmd_text[i])
		tween.tween_interval(0.05)
	
	tween.tween_interval(0.5)
	tween.tween_callback(reveal_menu_options)

func reveal_menu_options():
	return
	
