extends Control

@onready var options_panel     = $OptionsPanel
@onready var audio_panel       = $OptionsPanel/CenterContainer/VBoxContainer/AudioPanel
@onready var display_panel     = $OptionsPanel/CenterContainer/VBoxContainer/DisplayPanel
@onready var music_slider      = $OptionsPanel/CenterContainer/VBoxContainer/AudioPanel/MusicSlider
@onready var sfx_slider        = $OptionsPanel/CenterContainer/VBoxContainer/AudioPanel/SFXSlider
@onready var fullscreen_check  = $OptionsPanel/CenterContainer/VBoxContainer/DisplayPanel/FullscreenCheck
@onready var resolution_option = $OptionsPanel/CenterContainer/VBoxContainer/DisplayPanel/ResolutionOption
@onready var btn_audio         = $OptionsPanel/HBoxContainer/Button
@onready var btn_display       = $OptionsPanel/HBoxContainer/Button2
@onready var sfx_player        = $SFXPlayer
@onready var music_player      = $MusicPlayer

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.5))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(1.0))
	music_player.finished.connect(func(): music_player.play())
	
	options_panel.hide()
	_setup_resolution_options()
	_load_settings()
	_show_tab("Audio")
	
	var font = load("res://src/Fonts/PressStart2P-Regular.ttf")
	_apply_font($OptionsPanel, font)
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)
	$OptionsPanel/CloseButton.pressed.connect(_on_close_pressed)
	
	$OptionsPanel/HBoxContainer/Button.pressed.connect(func():
		sfx_player.play()
		_show_tab("Audio")
	)
	$OptionsPanel/HBoxContainer/Button2.pressed.connect(func():
		sfx_player.play()
		_show_tab("Display")
	)

func _on_music_player_finished() -> void:
	music_player.play()

# --- Tab ---

func _show_tab(tab: String) -> void:
	audio_panel.visible   = (tab == "Audio")
	display_panel.visible = (tab == "Display")
	btn_audio.modulate    = Color("#c8a96e") if tab == "Audio"   else Color(0.5, 0.5, 0.5, 1)
	btn_display.modulate  = Color("#c8a96e") if tab == "Display" else Color(0.5, 0.5, 0.5, 1)

# --- Ana butonlar ---

func _on_start_pressed() -> void:
	sfx_player.play()
	await sfx_player.finished
	get_tree().change_scene_to_file("res://src/Scenes/menu_2.tscn")

func _on_options_pressed() -> void:
	sfx_player.play()
	options_panel.show()

func _on_exit_pressed() -> void:
	sfx_player.play()
	get_tree().quit()

func _on_close_pressed() -> void:
	sfx_player.play()
	_save_settings()
	options_panel.hide()

# --- Audio ---

func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(value)
	)

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value)
	)

# --- Display ---

func _setup_resolution_options() -> void:
	resolution_option.clear()
	for res in RESOLUTIONS:
		resolution_option.add_item("%d x %d" % [res.x, res.y])

func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_selected(index: int) -> void:
	if not fullscreen_check.button_pressed:
		DisplayServer.window_set_size(RESOLUTIONS[index])

# --- Font ---

func _apply_font(node: Node, font: FontFile) -> void:
	if node is Control:
		node.add_theme_font_override("font", font)
		node.add_theme_font_size_override("font_size", 50)
	for child in node.get_children():
		_apply_font(child, font)

# --- Save / Load ---

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
	config.set_value("display", "resolution", resolution_option.selected)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		music_slider.value = 0.5
		sfx_slider.value   = 1.0
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.5))
		return
	music_slider.value = config.get_value("audio", "music", 0.5)
	sfx_slider.value   = config.get_value("audio", "sfx", 1.0)
	var fs = config.get_value("display", "fullscreen", false)
	fullscreen_check.button_pressed = fs
	_on_fullscreen_toggled(fs)
	resolution_option.select(config.get_value("display", "resolution", 0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_slider.value))
