extends Control

@onready var start_label = $StartPrompt
@onready var os_icon = $OSIcon
@onready var prompt_hbox = $ConsoleVBox/PromptHbox
@onready var console_vbox = $ConsoleVBox
@onready var start_prompt = $ConsoleVBox/PromptHbox/Hostname
@onready var command_input = $ConsoleVBox/PromptHbox/CommandInput
@onready var game_title = $ConsoleVBox/GameTitle
@onready var star_game = $ConsoleVBox/MenuOption1
@onready var options = $ConsoleVBox/MenuOption2
@onready var exit_game = $ConsoleVBox/MenuOption3
@onready var enter_option = $ConsoleVBox/Input/EnterOption
@onready var input_field = $ConsoleVBox/Input/InputField

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
		console_vbox.visible = true
		command_input.text = ""
		command_input.editable = false
	)

	var cmd_text = "./infiltrate.sh"
	for i in range(cmd_text.length()):
		tween.tween_callback(func(): command_input.text += cmd_text[i])
		tween.tween_interval(0.1)
	
	tween.tween_interval(0.5)
	tween.tween_callback(reveal_menu_options)

func reveal_menu_options():
	var menu_lines = [game_title, star_game, options, exit_game]

	var menu_tween = create_tween()

	for line in menu_lines:
		menu_tween.tween_callback(func():line.visible = true)
		menu_tween.tween_interval(0.4)

	menu_tween.tween_callback(func():
		enter_option.visible = true
		input_field.visible = true
		input_field.editable = true
		input_field.grab_focus()
	)
		
	
