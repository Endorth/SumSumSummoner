extends Node2D

class_name Portal
@onready var anim = $AnimationPlayer

var prepare_time : float = 0.5

var can_fail : bool = true
var can_press : bool = false
var is_perfect_summon : bool = false
var is_great_summon : bool = false
signal failed

func _ready():
	set_color()
	prepare_time = randf_range(0.5, 1.0)
	$Timer.start(prepare_time)
	anim.play("prepare")

func set_color():
	var r = randf_range(0.5, 0.9)
	var g = randf_range(0.5, 0.9)
	var b = randf_range(0.5, 0.9)
	modulate = Color(r,g,b)

func is_perf_summon():
	is_perfect_summon = true

func is_gr_summon():
	is_great_summon = true

func stop_portal():
	can_fail = false

func fail():
	if can_fail:
		failed.emit()

func _on_timer_timeout():
	can_press = true
	anim.play("FX")
