extends Node2D

func _ready() -> void:
	$Button.pressed.connect(_on_continue)

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Menu1.tscn")
