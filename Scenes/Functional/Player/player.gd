extends CharacterBody2D


@export var speed: float = 200.0
@export var sprintSpeed: float = 350.0
@export var sneakSpeed: float = 100.0

var movement_enabled: bool = true
var current_sprite: String = "walk_down"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WalkSprite.play()
	$WalkSprite.frame = 1 # this is the neutral down sprite.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Reset velocity
	velocity = Vector2.ZERO

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit() # Exit the game

	# check if R is pressed
	if Input.is_key_pressed(Key.KEY_R):
		# get game manager
		var game_manager = get_node("/root/GameManager")
		if game_manager:
			game_manager.level_fail() # Call level fail function in game manager
		return

	if not movement_enabled:
		return

	# Check input actions for movement. Up/down take priority.
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		if current_sprite != "walk_up":
			current_sprite = "walk_up"
			$WalkSprite.play("walk_up")

	elif Input.is_action_pressed("ui_down"):
		velocity.y += 1
		if current_sprite != "walk_down":
			current_sprite = "walk_down"
			$WalkSprite.play("walk_down")

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		if velocity.y == 0:
			if current_sprite != "walk_right":
				current_sprite = "walk_right"
				$WalkSprite.play("walk_right")

	elif Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		if velocity.y == 0:
			if current_sprite != "walk_left":
				current_sprite = "walk_left"
				$WalkSprite.play("walk_left")


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
