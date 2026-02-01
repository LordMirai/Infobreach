extends CharacterBody2D


@export var speed: float = 200.0
@export var sprintSpeed: float = 350.0
@export var sneakSpeed: float = 100.0

var movement_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WalkSprite.play()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Reset velocity
	velocity = Vector2.ZERO

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit() # Exit the game

	if not movement_enabled:
		return
		
	# Check input actions for movement
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		$PlayerSprite.flip_h = true
		$WalkSprite.play("walk_right")
		
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		$PlayerSprite.flip_h = false
		$WalkSprite.play("walk_left")

	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		$WalkSprite.play("walk_up")

	elif Input.is_action_pressed("ui_down"):
		velocity.y += 1
		$WalkSprite.play("walk_down")


	if velocity.length() > 0:
		var temp_speed = sneakSpeed if Input.is_action_pressed("sneak") else self.speed
		velocity = velocity.normalized() * (temp_speed if not Input.is_action_pressed("sprint") else sprintSpeed)
		if Input.is_action_pressed("sprint"):
			$WalkSprite.speed_scale = 1.5
		else:
			if Input.is_action_pressed("sneak"):
				$WalkSprite.speed_scale = 0.5
			else:
				$WalkSprite.speed_scale = 1.0
		move_and_slide()
	else:
		$WalkSprite.speed_scale = 0
