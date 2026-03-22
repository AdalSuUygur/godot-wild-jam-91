extends Node2D

const NUMBER_COUNT := 40

func _draw() -> void:
	var radius := 100.0
	

	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color("#5a3e1a"), 2.0)
	

	draw_arc(Vector2.ZERO, radius - 20.0, 0, TAU, 64, Color("#3a2a0e"), 1.0)
	

	draw_circle(Vector2.ZERO, radius - 22.0, Color("#120e04"))
	

	for i in NUMBER_COUNT:
		var angle := (float(i) / NUMBER_COUNT) * TAU - PI / 2.0
		var is_major := i % 5 == 0
		var tick_out := radius - 2.0
		var tick_in := radius - (14.0 if is_major else 7.0)
		var from := Vector2(cos(angle), sin(angle)) * tick_in
		var to := Vector2(cos(angle), sin(angle)) * tick_out
		draw_line(from, to, Color("#c8a86b") if is_major else Color("#4a3618"), 1.5 if is_major else 0.8)
	

	draw_circle(Vector2.ZERO, 8.0, Color("#3a2a0e"))
	draw_circle(Vector2.ZERO, 4.0, Color("#c8a86b"))
