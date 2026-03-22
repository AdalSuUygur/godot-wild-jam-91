extends Control

func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)

func _process(delta: float) -> void:
	pass

func _on__pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/chapter_1.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Menu1.tscn")
