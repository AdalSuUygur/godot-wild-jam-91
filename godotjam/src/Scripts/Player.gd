extends CharacterBody2D

const SPEED := 120.0
const RUN_SPEED := 200.0
const JUMP_VELOCITY := -200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_label: Label = get_node("../Door/InteractLabel")
@onready var case_label: Label = get_node("../Case/CaseInteractLabel")
@onready var safe = get_node("../Case")
@onready var diamond_hud: TextureRect = get_node("/root/Chapter1/HUD/DiamondHUD")
@onready var timer_label: Label = get_node("/root/Chapter1/HUD/TimerLabel")

var near_door := false
var near_case := false
var door_unlocked := false
var case_unlocked := false
var time_left: float = 80.0  

func _ready() -> void:
	door_unlocked = Global.door_unlocked
	case_unlocked = Global.case_unlocked
	if door_unlocked:
		get_node("../Door/CollisionShape2D").disabled = true
		door_label.visible = false
	diamond_hud.visible = false

func _physics_process(delta: float) -> void:
	if Global.minigame_active:
		return


	time_left -= delta
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	if time_left <= 0:
		get_tree().change_scene_to_file("res://src/Scenes/TimeOut.tscn")


	if global_position.distance_to(safe.global_position) < 50:
		near_case = true
		if not case_unlocked:
			case_label.visible = true
	else:
		near_case = false
		case_label.visible = false

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("Left", "Right")
	var is_running := Input.is_action_pressed("Run")
	var current_speed := RUN_SPEED if is_running else SPEED

	if direction != 0:
		velocity.x = direction * current_speed
		animated_sprite.flip_h = direction < 0
		if is_running:
			if animated_sprite.animation != "Run":
				animated_sprite.play("Run")
		else:
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if animated_sprite.animation != "Idle":
			animated_sprite.play("Idle")

	move_and_slide()


	if Global.door_unlocked and not door_unlocked:
		door_unlocked = true
		get_node("../Door/CollisionShape2D").disabled = true
		door_label.visible = false
		near_door = false


	if Global.case_unlocked and not case_unlocked:
		print("diamond gösteriliyor!")
		case_unlocked = true
		case_label.visible = false
		near_case = false
		diamond_hud.visible = true


	if Input.is_action_just_pressed("Interact") and near_door and not door_unlocked:
		door_label.visible = false
		Global.minigame_active = true
		var lockpick_scene = load("res://src/MiniGames/Lockpicking/lockpick_minigame.tscn")
		var lockpick_instance = lockpick_scene.instantiate()
		var canvas = CanvasLayer.new()
		canvas.layer = 10
		get_tree().root.add_child(canvas)
		canvas.add_child(lockpick_instance)


	if Input.is_action_just_pressed("Interact") and near_case and not case_unlocked:
		case_label.visible = false
		Global.minigame_active = true
		var safe_scene = load("res://src/MiniGames/SafeCracker/safeCracker_minigame.tscn")
		var safe_instance = safe_scene.instantiate()
		var canvas = CanvasLayer.new()
		canvas.layer = 10
		get_tree().root.add_child(canvas)
		canvas.add_child(safe_instance)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Down") and is_on_floor():
		position.y += 1

func _on_door_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not door_unlocked:
		near_door = true
		door_label.visible = true

	if body.name == "Player" and Global.case_unlocked:
		get_tree().change_scene_to_file("res://src/Scenes/GameWin.tscn")

func _on_door_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		near_door = false
		door_label.visible = false
