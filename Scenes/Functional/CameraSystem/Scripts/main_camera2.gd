extends Node2D

const Interactable = preload("res://Scenes/Functional/Interactables/Base/interactable.gd")

var currentFrame: int =  0
const TIME_OF_WARNING : int = 5
const TIME_OF_DETECTION: int = 5 

func _ready() -> void:
	$CameraSprites.set_frame(0)
	$CameraSprites.set_speed_scale(0.0)
	$Timer.start(3)
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
	$CameraSprites.set_frame(currentFrame)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Player"):
		$WarningSprites.set_frame(1)
		$WarnTimer.start(TIME_OF_WARNING)
		$DangerTimer.start(TIME_OF_WARNING+TIME_OF_DETECTION)
		print("WARNING YOU ARE BEING DETECTED")




func _on_warn_timer_timeout() -> void:
	$WarnTimer.stop()
	print("LAST WARNING THE MAINFRAME IS CLOSE TO IDENTIFYING YOU")
	$WarningSprites.set_frame(2)
	pass # Replace with function body.
	
func _on_danger_timer_timeout() -> void:
	$DangerTimer.stop()
	print("GAME OVER THE POLICE IS ON THEIR WAY")
	$WarningSprites.set_frame(0)
	pass # Replace with function body.

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		print("MANAGED TO GET OUT OF DETECTION")
		$WarningSprites.set_frame(0)
		$DangerTimer.stop()
		$WarnTimer.stop()
	# Replace with function body.
