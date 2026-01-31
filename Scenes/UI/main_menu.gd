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
@onready var big_game_title = $BigGameTitle
@onready var logo = $Logo
@onready var os_name = $OSName

var is_booted = false

func _ready() -> void:
	input_field.text_submitted.connect(_on_input_submitted)

func _input(event: InputEvent) -> void:	
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F1:
		start_hacking()
	if not is_booted and event is InputEventKey and event.is_pressed():
		var is_just_modifier = event.keycode in [
			KEY_CTRL, KEY_SHIFT, KEY_ALT, KEY_META, KEY_CAPSLOCK, KEY_TAB
		]
		
		var is_holding_modifier = event.ctrl_pressed or event.alt_pressed or event.shift_pressed or event.meta_pressed

		if not is_just_modifier and not is_holding_modifier:
			boot_system()

func boot_system():
	is_booted = true
	start_label.visible = false
	big_game_title.visible = false
	logo.visible = false
	os_name.visible = false
	
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
		
func _on_input_submitted(new_text: String):
	var choice = new_text.strip_edges()

	match choice:
		"1":
			start_hacking()
		"2":
			open_settings()
		"3":
			get_tree().quit()
		_: 
			invalid_command()

func start_hacking():
	get_tree().change_scene_to_file("res://Scenes/Levels/first_level.tscn")

func invalid_command():
	var flash = create_tween()

	flash.tween_property(input_field, "modulate", Color.RED, 0.1)
	flash.tween_property(input_field, "modulate", Color.WHITE, 0.1)

	input_field.text = ""

func open_settings():
	print("OPEN SETTINGS")
