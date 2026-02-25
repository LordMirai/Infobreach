extends Node2D

const Interactable = preload("res://Scenes/Functional/Interactables/Base/interactable.gd")

var currentFrame: int = 0
@export var TIME_OF_WARNING: int = 2
@export var TIME_OF_DETECTION: float = 0.8
var isCameraDisabled: int = 0

var beforeHackFrame: int = 0
var beforeHackLoopback: int = -1

@onready var cameraFOVPolygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D
var currentColor = Color()
var colorFOV = Color(0, 1, 0.5, 0.35)
var colorWarn = Color(0, 1, 1, 0.45)
var colorDetect = Color(1, 0, 0, 0.45)

func _ready() -> void:
	$CameraSprites.set_frame(0)
	$CameraSprites.set_speed_scale(0.0)
	$Timers/Timer.start(3)
	$WarningSprites.set_frame(0)
	currentColor = colorFOV

func _draw() -> void:
	if cameraFOVPolygon:
		draw_set_transform($Area2D.position, $Area2D.rotation, cameraFOVPolygon.scale)
		draw_polygon(cameraFOVPolygon.polygon, [currentColor])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _process(delta: float) -> void:
	queue_redraw()


var loopback = -1

func _on_timer_timeout() -> void:
	if currentFrame == 1 || currentFrame == 3:
		loopback = loopback * -1

	$Area2D.rotate(deg_to_rad(loopback * 45))

	currentFrame = (currentFrame + 1) % 4
	$CameraSprites.set_frame(currentFrame)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") && !isCameraDisabled:
		$WarningSprites.set_frame(1)
		$Timers/WarnTimer.start(TIME_OF_WARNING)
		currentColor = colorWarn

func _on_warn_timer_timeout() -> void:
	$Timers/WarnTimer.stop()
	print("LAST WARNING THE MAINFRAME IS CLOSE TO IDENTIFYING YOU")
	currentColor = colorDetect
	$Timers/DangerTimer.start(TIME_OF_DETECTION)
	$WarningSprites.set_frame(2)


func _on_danger_timer_timeout() -> void:
	$Timers/DangerTimer.stop()
	print("GAME OVER THE POLICE IS ON THEIR WAY")
	$WarningSprites.set_frame(0)
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.level_fail() # Call level fail function in game manager


func _on_area_2d_area_exited(area: Area2D) -> void:
	# print("camera is disabled? y n? ")
	# print(isCameraDisabled)
	# print(area)
	if area.get_parent().is_in_group("Player") && !isCameraDisabled:
		print("MANAGED TO GET OUT OF DETECTION")
		$WarningSprites.set_frame(0)
		$Timers/DangerTimer.stop()
		$Timers/WarnTimer.stop()
		currentColor = colorFOV

	# Replace with function body.


func _on_disabled_timer_timeout() -> void:
	$Timers/Timer.paused = false
	$Timers/DangerTimer.paused = false
	$Timers/WarnTimer.paused = false
	currentFrame = beforeHackFrame
	loopback = beforeHackLoopback
	isCameraDisabled = 0
	$WarningSprites.set_frame(0)
	$Timers/DisabledTimer.stop()
	$DeviceInteractable.hacked = false
	$CameraSprites.modulate.a = 1.0
	currentColor.a = 1.0
	currentColor = colorFOV
