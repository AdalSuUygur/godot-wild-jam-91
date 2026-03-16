extends CharacterBody2D

const SPEED := 120.0
const JUMP_VELOCITY := -250.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input
	var direction := Input.get_axis("Left", "Right")

	if direction != 0:
		velocity.x = direction * SPEED
		
		# Flip sprite
		animated_sprite.flip_h = direction < 0
		
		if animated_sprite.animation != "Walk":
			animated_sprite.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if animated_sprite.animation != "Idle":
			animated_sprite.play("Idle")

	move_and_slide()
