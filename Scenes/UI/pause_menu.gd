extends CanvasLayer

func _ready() -> void:
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

	if visible:
		print()
	else:
		print()

func _on_resume_pressed():
	get_tree().paused = false
	visible = false

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
