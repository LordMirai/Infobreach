extends TextureButton

signal binary_toggled

@export var index: int
@export var value: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_toggled(toggled_on: bool) -> void:
	value = (1 << index) if toggled_on else 0
	"Button index {} pressed, state {}, value {}"
	print("Button index %d pressed, state %s, value %d" % [index, str(toggled_on), value])
	
	emit_signal("binary_toggled")
