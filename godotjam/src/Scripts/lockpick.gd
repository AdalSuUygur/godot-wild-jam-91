class_name Lockpick2D extends Node2D

@export var max_range: float = 180.0
@export var sensitivity: float = 0.3
@export var keyhole_speed: float = 120.0
@export var sweet_spot_range: float = 15.0
@export var max_breaks: int = 3

@onready var lockpick_pivot: Node2D            = $LockpickPivot
@onready var keyhole_pivot: Node2D             = $KeyholePivot
@onready var sound_move: AudioStreamPlayer2D   = $SoundMove
@onready var sound_unlock: AudioStreamPlayer2D = $SoundUnlock
@onready var sound_break: AudioStreamPlayer2D  = $SoundBreak

const MIN_RANGE:           float = -90.0
const MAX_RANGE:           float =  90.0
const UNLOCK_ANGLE:        float =  90.0
const BREAK_ANGLE:         float = -20.0
const LOCKPICK_BREAK_TIME: float =  0.4

var is_unlocked:   bool  = false
var is_turning:    bool  = false
var sweet_spot:    float = 0.0
var lockpick_spot: float = 0.0
var break_timer:   float = 0.0
var is_breaking:   bool  = false
var shake_time:    float = 0.0
var pressure_time: float = 0.0
var break_count:   int   = 0

signal unlocked
signal lockpick_broken
signal out_of_picks

func _ready() -> void:
	position = get_viewport().get_visible_rect().size / 2
	$KeyholePivot.get_node("KeyholeVisual").position = Vector2.ZERO
	unlocked.connect(_on_unlocked)
	lockpick_broken.connect(_on_lockpick_broken)
	out_of_picks.connect(_on_out_of_picks)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_place_sweet_spot()
	lockpick_pivot.rotation_degrees = 0.0
	sound_move.play()
	sound_move.finished.connect(func(): sound_move.play())

func _input(event: InputEvent) -> void:
	if is_unlocked or is_breaking:
		return
	if event is InputEventMouseMotion and not is_turning:
		lockpick_pivot.rotation_degrees += event.relative.x * sensitivity
		lockpick_pivot.rotation_degrees = clamp(lockpick_pivot.rotation_degrees, MIN_RANGE, MAX_RANGE)

func _physics_process(delta: float) -> void:
	if is_unlocked:
		return
	if is_breaking:
		_handle_breaking(delta)
		return
	lockpick_spot = remap(lockpick_pivot.rotation_degrees, MIN_RANGE, MAX_RANGE, 0.0, max_range)
	_handle_keyhole(delta)

func _handle_keyhole(delta: float) -> void:
	is_turning = Input.is_physical_key_pressed(KEY_SPACE)
	var distance: float = abs(lockpick_spot - sweet_spot)
	var outside_sweet_spot: bool = distance > sweet_spot_range

	if is_turning:
		var closeness: float = clamp(1.0 - (distance / sweet_spot_range), 0.0, 1.0)
		keyhole_pivot.rotation_degrees += keyhole_speed * closeness * delta

		if outside_sweet_spot:
			shake_time += delta
			pressure_time += delta
			lockpick_pivot.rotation_degrees += sin(shake_time * 25.0) * 1.5
			if pressure_time >= 1.0:
				_start_breaking()
				return
		else:
			pressure_time = 0.0
			shake_time = 0.0
	else:
		shake_time = 0.0
		keyhole_pivot.rotation_degrees = lerp(keyhole_pivot.rotation_degrees, 0.0, 8.0 * delta)

	keyhole_pivot.rotation_degrees = clamp(keyhole_pivot.rotation_degrees, BREAK_ANGLE, UNLOCK_ANGLE)

	if keyhole_pivot.rotation_degrees >= UNLOCK_ANGLE - 0.5:
		is_unlocked = true
		unlocked.emit()

func _start_breaking() -> void:
	is_breaking = true
	break_timer = 0.0
	pressure_time = 0.0

func _handle_breaking(delta: float) -> void:
	break_timer += delta
	lockpick_pivot.rotation_degrees += sin(break_timer * 40.0) * 3.0
	if break_timer >= LOCKPICK_BREAK_TIME:
		is_breaking = false
		break_count += 1
		lockpick_broken.emit()
		if break_count >= max_breaks:
			out_of_picks.emit()
		else:
			_reset_lockpick()

func _reset_lockpick() -> void:
	lockpick_pivot.rotation_degrees = 0.0
	keyhole_pivot.rotation_degrees  = 0.0
	shake_time = 0.0
	_place_sweet_spot()
	sound_move.play()

func _place_sweet_spot() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	sweet_spot = snappedf(rng.randf_range(0.0, max_range), 1.0)

func _on_unlocked() -> void:
	is_unlocked = true
	sound_move.stop()
	sound_unlock.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.door_unlocked = true
	Global.minigame_active = false
	await get_tree().create_timer(1.0).timeout
	get_parent().queue_free()

func _on_lockpick_broken() -> void:
	sound_move.stop()
	sound_break.play()

func _on_out_of_picks() -> void:
	sound_move.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.minigame_active = false
	await get_tree().create_timer(1.0).timeout
	get_parent().queue_free()
	get_tree().change_scene_to_file("res://src/Scenes/GameOver.tscn")
