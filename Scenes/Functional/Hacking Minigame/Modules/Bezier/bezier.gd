extends "res://Scenes/Functional/Hacking Minigame/Modules/Module Base/base_module.gd"

@onready var draggable_point: PackedScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Bezier/draggable_point.tscn")
@onready var goal_point: PackedScene = preload("res://Scenes/Functional/Hacking Minigame/Modules/Bezier/goal_point.tscn")
@onready var line: Line2D = $Container/Line2D
@onready var container: PanelContainer = $Container
@onready var goal_points: Node = $Container/GoalPoints
@onready var curve_points: Node = $Container/CurvePoints
@onready var timer: Node = $Timer
@onready var timer_text: Label = $Container/Background/Timer
var curve_point_array: PackedVector2Array
#var goal_point_array: Array[Vector2]
var curve: Curve2D
const CURVE_POINTS: int = 4 # don't change yet please
const GOAL_POINTS: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_module()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(CURVE_POINTS):
		curve_point_array[i] = curve_points.get_child(i).position
	draw_curved_line()
	check_targets()
	timer_text.text = "%0.2f" % timer.time_left


func random_position(x: int, y: int) -> Vector2:
	return Vector2(randi_range(0, x), randi_range(0, y))


func create_curve_points() -> void:
	for i in range(CURVE_POINTS):
		var point = draggable_point.instantiate()
		point.position = random_position(container.size.x, container.size.y)
		point.bounds = container.size
		point.top_left = position
		print(point.bounds)
		curve_point_array.append(point.position)
		curve_points.add_child(point)
	

func create_goal_points() -> void:
	for i in range(GOAL_POINTS):
		var point = goal_point.instantiate()
		var random_point_curve = curve.get_baked_points()[randi() % curve.get_baked_points().size()]
		point.position = random_point_curve
		goal_points.add_child(point)
		#goal_point_array.append(point)
		
		
func generate_curve() -> void:
	# todo: generalise bezier curve for n points
	curve.add_point(curve_point_array[0], Vector2.ZERO,
			curve_point_array[1] - curve_point_array[0])
	curve.add_point(curve_point_array[3], curve_point_array[2] - curve_point_array[3],
			Vector2.ZERO)
		
	
func draw_curved_line() -> void:
	curve.clear_points()
	generate_curve()
	line.clear_points()
	for point in curve.get_baked_points():
		line.add_point(point)
		

func check_targets() -> void:
	if Input.is_action_pressed("click"):
		var current_point: int = 0
		var baked: Array = Array(curve.get_baked_points())
		for goal in goal_points.get_children():
			goal.is_intersected = baked.any(
				func(point):
					return goal.detect_input(point + position)
			)
		#print(goal_points.get_children().size())
		if goal_points.get_children().all(
			func(goal):
				return goal.is_intersected
		):
			timer.paused = true
			complete_module()


func _on_timer_timeout() -> void:
	fail_module()
	reset_module()


func complete_module() -> void:
	super()
	for node in curve_points.get_children():
		node.is_draggable = false
		
func reset_module() -> void:
	for node in curve_points.get_children():
		curve_points.remove_child(node)
		node.queue_free()
	for node in goal_points.get_children():
		goal_points.remove_child(node)
		node.queue_free()
	curve_point_array.clear()
	
	curve = Curve2D.new()
	create_curve_points()
	generate_curve()
	create_goal_points()
	for i in range(CURVE_POINTS):
		curve_points.get_child(i).position = random_position(container.size.x, container.size.y)

	timer.start()
