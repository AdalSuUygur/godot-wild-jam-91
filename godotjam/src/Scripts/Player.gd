extends CharacterBody2D

const SPEED := 120.0
const RUN_SPEED := 200.0
const JUMP_VELOCITY := -250.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	var direction := Input.get_axis("Left", "Right")
	var is_running := Input.is_action_pressed("Run")

	var current_speed := SPEED
	if is_running:
		current_speed = RUN_SPEED

	if direction != 0:
		velocity.x = direction * current_speed
		
		
		animated_sprite.flip_h = direction < 0
		
		if is_running:
			if animated_sprite.animation != "Run":
				animated_sprite.play("Run")
		else:
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if animated_sprite.animation != "Idle":
			animated_sprite.play("Idle")

	move_and_slide()
