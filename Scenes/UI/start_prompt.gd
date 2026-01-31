extends Label


@export var move_interval: float = 1.3
@export var step_height: float = 16.0

var time_passed: float = 0.0
var step_index: int = 0

# Middle -> Up -> Middle -> Down
var steps = [0 , -1, 0, 1]

@onready var original_y = position.y

func _process(delta: float) -> void:
	time_passed += delta

	if time_passed >= move_interval:
		time_passed = 0.0
		cycle_position()

func cycle_position():
	step_index = (step_index + 1) % steps.size()
	var current_offset = steps[step_index] * step_height

	position.y = original_y + current_offset
