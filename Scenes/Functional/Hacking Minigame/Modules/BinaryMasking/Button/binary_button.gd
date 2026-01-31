extends TextureButton

@export var index: int
@export var value: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_toggled(toggled_on: bool) -> void:
	value = (1 << index) if toggled_on else 0
