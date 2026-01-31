extends Node2D

const Interactable = preload("res://Scenes/Functional/Interactables/Base/interactable.gd")

var currentFrame: int =  0
const TIME_OF_WARNING : int = 5
const TIME_OF_DETECTION: int = 5 
var isCameraDisabled : int = 0 

var beforeHackFrame: int =0
var beforeHackLoopback: int = -1

func _ready() -> void:
	$CameraSprites.set_frame(0)
	$CameraSprites.set_speed_scale(0.0)
	$Timers/Timer.start(3)
	$WarningSprites.set_frame(0)
	
	
func _process(delta: float) -> void:
	pass
	
	
var loopback = -1

func _on_timer_timeout() -> void:
	
	print(currentFrame)
	if currentFrame == 1 || currentFrame == 3 :
		loopback = loopback * -1
		
	$Area2D.rotate(deg_to_rad(loopback *45))
	print(loopback * 45)
	
	currentFrame = (currentFrame+1)%4
	print((currentFrame+1)%4)
	$CameraSprites.set_frame(currentFrame)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Player") && !isCameraDisabled:
		$WarningSprites.set_frame(1)
		$Timers/WarnTimer.start(TIME_OF_WARNING)
		$Timers/DangerTimer.start(TIME_OF_WARNING+TIME_OF_DETECTION)
		print("WARNING YOU ARE BEING DETECTED")

func _on_warn_timer_timeout() -> void:
	$Timers/WarnTimer.stop()
	print("LAST WARNING THE MAINFRAME IS CLOSE TO IDENTIFYING YOU")
	$WarningSprites.set_frame(2)
	pass # Replace with function body.
	
func _on_danger_timer_timeout() -> void:
	$Timers/DangerTimer.stop()
	print("GAME OVER THE POLICE IS ON THEIR WAY")
	$WarningSprites.set_frame(0)
	pass # Replace with function body.

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player") && !isCameraDisabled:
		print("MANAGED TO GET OUT OF DETECTION")
		$WarningSprites.set_frame(0)
		$Timers/DangerTimer.stop()
		$Timers/WarnTimer.stop()
	# Replace with function body.
	
	
func _on_disabled_timer_timeout() -> void:
	$Timers/Timer.paused = false
	currentFrame = beforeHackFrame
	loopback = beforeHackLoopback
	isCameraDisabled = 0
	$WarningSprites.set_frame(0)
	$Timers/DisabledTimer.stop()
	$DeviceInteractable.hacked = false
	$CameraSprites.modulate.a = 1.0
	
