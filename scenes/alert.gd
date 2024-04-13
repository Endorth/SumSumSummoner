extends Node2D


func set_alert(col : Color, txt : String, size : float):
	$Label.text = str(txt)
	$Label.modulate = col
	scale = Vector2(size,size)

	var final_x_pos : int = randi_range(-10, 10) + global_position.x
	var final_y_pos : int = randi_range(-30, -80) + global_position.y
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, 'global_position', Vector2(final_x_pos, final_y_pos), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)

