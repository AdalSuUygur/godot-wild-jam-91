extends Node2D

# ── Sabitler ──────────────────────────────────────────────────────────────
const NUMBER_COUNT := 40
const MAX_ATTEMPTS := 5
const TOTAL_STEPS := 3
const MAX_RETRIES := 3
const SNAP_TOLERANCE := 1

# ── Durum değişkenleri ─────────────────────────────────────────────────────
var combination: Array[int] = []
var current_step := 0
var locked_steps: Array[int] = []
var attempts := 0
var retries := 0

var dial_angle := 0.0
var current_number := 0
var is_dragging := false
var drag_start_angle := 0.0
var dial_start_angle := 0.0

# ── Node referansları ──────────────────────────────────────────────────────
@onready var hint_label: Label = $SafePanel/VBox/HintLabel
@onready var steps_label: Label = $SafePanel/VBox/StepsLabel
@onready var slots_row: HBoxContainer = $SafePanel/VBox/SlotsRow
@onready var dots_row: HBoxContainer = $SafePanel/VBox/DotsRow
@onready var dial_pivot: Node2D = $SafePanel/VBox/DialArea/DialPivot
@onready var indicator: Polygon2D = $SafePanel/VBox/DialArea/DialPivot/Indicator
@onready var center_label: Label = $SafePanel/VBox/DialArea/DialPivot/CenterLabel
@onready var vib_bars: HBoxContainer = $SafePanel/VBox/VibBars
@onready var confirm_btn: Button = $SafePanel/VBox/ButtonsRow/ConfirmBtn
@onready var reset_btn: Button = $SafePanel/VBox/ButtonsRow/ResetBtn
@onready var win_overlay: ColorRect = $WinOverlay
@onready var fail_overlay: ColorRect = $FailOverlay
@onready var dial_area: Control = $SafePanel/VBox/DialArea
@onready var tick_sound: AudioStreamPlayer = $TickSound
@onready var beep_sound: AudioStreamPlayer = $BeepSound

# ── Hazırlık ───────────────────────────────────────────────────────────────
func _ready() -> void:
	_new_combination()
	confirm_btn.pressed.connect(_on_confirm)
	reset_btn.pressed.connect(_on_reset_dial)
	$WinOverlay/VBox/ContinueBtn.pressed.connect(_on_continue)
	$FailOverlay/VBox/RetryBtn.pressed.connect(_on_retry)
	dial_area.gui_input.connect(_on_dial_input)
	tick_sound.play()
	beep_sound.play()
	_render_all()

# ── Kombinasyon ────────────────────────────────────────────────────────────
func _new_combination() -> void:
	combination.clear()
	while combination.size() < TOTAL_STEPS:
		var n := randi() % NUMBER_COUNT
		if not combination.has(n):
			combination.append(n)

# ── Yardımcı fonksiyonlar ──────────────────────────────────────────────────
func _angle_to_number(angle: float) -> int:
	return int(round(fmod(angle, 360.0) / 360.0 * NUMBER_COUNT)) % NUMBER_COUNT

func _vec_to_angle(v: Vector2) -> float:
	return rad_to_deg(atan2(v.y, v.x))

func _angle_diff(a: float, b: float) -> float:
	return fmod(a - b + 540.0, 360.0) - 180.0

func _get_proximity() -> float:
	if current_step >= TOTAL_STEPS:
		return 0.0
	var target := combination[current_step]
	var diff := mini(abs(current_number - target), NUMBER_COUNT - abs(current_number - target))
	return 1.0 - float(diff) / float(NUMBER_COUNT / 2)

# ── Kadran döndürme ────────────────────────────────────────────────────────
func _rotate_dial(delta_deg: float) -> void:
	var prev_number := current_number
	dial_angle = fmod(dial_angle + delta_deg + 360.0, 360.0)
	current_number = _angle_to_number(dial_angle)
	if current_number != prev_number:
		_play_tick()
	_update_dial_visuals()

func _on_dial_input(event: InputEvent) -> void:
	var center := dial_area.size / 2.0
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_angle = _vec_to_angle(event.position - center)
				dial_start_angle = dial_angle
			else:
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		var prev := current_number
		var a := _vec_to_angle(event.position - center)
		var delta := _angle_diff(a, drag_start_angle)
		dial_angle = fmod(dial_start_angle + delta + 360.0, 360.0)
		current_number = _angle_to_number(dial_angle)
		if current_number != prev:
			_play_tick()
		_update_dial_visuals()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left"):
		_rotate_dial(-9.0)
	elif event.is_action_pressed("Right"):
		_rotate_dial(9.0)
	elif event.is_action_pressed("ui_accept"):
		_on_confirm()

# ── Onay ───────────────────────────────────────────────────────────────────
func _on_confirm() -> void:
	if locked_steps.size() >= TOTAL_STEPS:
		return
	attempts += 1
	var target := combination[current_step]
	var diff := mini(abs(current_number - target), NUMBER_COUNT - abs(current_number - target))
	if diff <= SNAP_TOLERANCE:
		locked_steps.append(current_step)
		current_step += 1
		_render_all()
		if locked_steps.size() >= TOTAL_STEPS:
			await get_tree().create_timer(0.5).timeout
			win_overlay.visible = true
	else:
		_shake()
		_render_all()
		if attempts >= MAX_ATTEMPTS:
			await get_tree().create_timer(0.5).timeout
			Global.minigame_active = false
			get_parent().queue_free()
			get_tree().change_scene_to_file("res://src/Scenes/MainMenu.tscn")

func _on_reset_dial() -> void:
	dial_angle = 0.0
	current_number = 0
	_update_dial_visuals()

func _on_continue() -> void:
	Global.case_unlocked = true
	Global.minigame_active = false
	get_parent().queue_free()

func _on_retry() -> void:
	retries += 1
	if retries >= MAX_RETRIES:
		Global.minigame_active = false
		get_parent().queue_free()
		get_tree().change_scene_to_file("res://src/Scenes/MainMenu.tscn")
		return
	combination.clear()
	current_step = 0
	locked_steps.clear()
	attempts = 0
	dial_angle = 0.0
	current_number = 0
	fail_overlay.visible = false
	_new_combination()
	_render_all()

# ── Görsel güncelleme ──────────────────────────────────────────────────────
func _render_all() -> void:
	_update_dial_visuals()
	_update_slots()
	_update_dots()
	_update_steps_label()

func _update_dial_visuals() -> void:
	dial_pivot.rotation_degrees = dial_angle
	dial_pivot.queue_redraw()
	center_label.text = "%02d" % current_number
	var p := _get_proximity()
	if p > 0.8:
		indicator.color = Color("#cc4a4a")
	elif p > 0.5:
		indicator.color = Color("#d4a44c")
	else:
		indicator.color = Color("#c8a86b")
	_update_vib_bars(p)
	_play_beep(p)

func _update_vib_bars(proximity: float) -> void:
	var bars := vib_bars.get_children()
	var count := bars.size()
	for i in count:
		var bar: ColorRect = bars[i]
		var center_dist: float = abs(float(i) - float(count) / 2.0) / (float(count) / 2.0)
		var base: float = proximity * (1.0 - center_dist * 0.5)
		var noise: float = (randf() * 0.4 - 0.2) * proximity
		var h: float = maxf(4.0, (base + noise) * 36.0)
		bar.custom_minimum_size.y = h
		if proximity > 0.8:
			bar.color = Color("#cc4a4a")
		elif proximity > 0.5:
			bar.color = Color("#d4a44c")
		elif proximity > 0.2:
			bar.color = Color("#6b5530")
		else:
			bar.color = Color("#2a1e08")

func _update_slots() -> void:
	var slots := slots_row.get_children()
	for i in TOTAL_STEPS:
		if i >= slots.size():
			break
		var slot: PanelContainer = slots[i]
		var num_label: Label = slot.get_node("VBox/NumberLabel")
		if locked_steps.has(i):
			num_label.text = "%02d" % combination[i]
			num_label.add_theme_color_override("font_color", Color("#6dcc5a"))
		elif i == current_step:
			num_label.text = "--"
			num_label.add_theme_color_override("font_color", Color("#d4a44c"))
		else:
			num_label.text = "--"
			num_label.add_theme_color_override("font_color", Color("#4a3618"))

func _update_dots() -> void:
	var dots := dots_row.get_children()
	for i in TOTAL_STEPS:
		if i >= dots.size():
			break
		var dot: ColorRect = dots[i]
		if locked_steps.has(i):
			dot.color = Color("#6dcc5a")
		elif i == current_step:
			dot.color = Color("#d4a44c")
		else:
			dot.color = Color("#2a1e08")

func _update_steps_label() -> void:
	steps_label.text = "ATTEMPTS: %d/%d   STEP: %d/%d" % [
		attempts, MAX_ATTEMPTS,
		mini(current_step + 1, TOTAL_STEPS), TOTAL_STEPS
	]

# ── Ses ───────────────────────────────────────────────────────────────────
func _play_tick() -> void:
	var playback := tick_sound.get_stream_playback()
	if playback == null:
		return
	var mix_rate: float = tick_sound.stream.mix_rate
	var frames: int = int(mix_rate * 0.03)
	for i in frames:
		var t: float = float(i) / mix_rate
		var sample: float = sin(TAU * 800.0 * t) * exp(-t * 80.0) * 0.3
		playback.push_frame(Vector2(sample, sample))

func _play_beep(proximity: float) -> void:
	if proximity < 0.3:
		return
	var playback := beep_sound.get_stream_playback()
	if playback == null:
		return
	var freq: float = lerp(200.0, 600.0, proximity)
	var volume: float = lerp(0.05, 0.25, proximity)
	var mix_rate: float = beep_sound.stream.mix_rate
	var frames: int = int(mix_rate * 0.06)
	for i in frames:
		var t: float = float(i) / mix_rate
		var envelope: float = exp(-t * 20.0)
		var sample: float = sin(TAU * freq * t) * envelope * volume
		playback.push_frame(Vector2(sample, sample))

# ── Sarsma efekti ──────────────────────────────────────────────────────────
func _shake() -> void:
	var original := position
	for i in 6:
		position.x = original.x + (8.0 if i % 2 == 0 else -8.0)
		await get_tree().create_timer(0.05).timeout
	position = original
