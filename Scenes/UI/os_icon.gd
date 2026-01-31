extends RichTextLabel

@export var wiggle_amplitude: float = 20.0 # up/down movement
@export var wiggle_speed: float = 2.2 # speed of the movement	

var time_passed: float = 0.0
@onready var inital_y: float = position.y

func _process(delta: float) -> void:
	time_passed += delta
	
	var offset = sin(time_passed * wiggle_speed) * wiggle_amplitude
	
	position.y = inital_y + offset
