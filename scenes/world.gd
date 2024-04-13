extends Node2D



var summSCN = preload("res://scenes/summoner.tscn")
var alertSCN = preload("res://scenes/alert.tscn")
@onready var gui = $CanvasLayer/GUI
@onready var summoners = $Summoners
@onready var remote_tr = $RemoteTr
@onready var camera_2d = $Camera2D

var current_summoner : Summoner = null
var summoner_list : Array[Summoner] = []

var max_summoners : int = 100

var summon_score : int = 0
var is_game_over : bool = false
var can_reload : bool = false
var curr_combo : int = 0
var max_combo : int = 0
var points : int = 0

var min_zoom : float = 0.4
var max_zoom : float = 1.0
var zoom = 1.0

func _input(_event):
	if Input.is_action_just_pressed('ui_accept'):
		if is_game_over:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

	if Input.is_action_just_pressed('ui_select'):
		assert(current_summoner, ' no has current summoner')
		if not is_game_over:
			if current_summoner.portal.can_press:
				if current_summoner.portal.is_perfect_summon:
					add_new_summoner(current_summoner.portal.global_position, 3)
				elif current_summoner.portal.is_great_summon:
					add_new_summoner(current_summoner.portal.global_position, 2)
				else:
					add_new_summoner(current_summoner.portal.global_position, 1)
			else:
				current_summoner.portal.anim.play("explosion")
				current_summoner.portal.stop_portal()
				failed()
		else:
			if can_reload:
				get_tree().reload_current_scene()

func _ready():
	add_new_summoner(Vector2.ZERO, 0)


func _process(delta):
	if not is_game_over and current_summoner:
		current_summoner.pivot.look_at(get_global_mouse_position())
		current_summoner.portal.global_position = current_summoner.portal_position.global_position

func add_alert(pos, col : Color, txt : String, size : float):
	var a = alertSCN.instantiate()
	add_child(a)
	a.global_position = pos
	a.set_alert(col, txt, size)

func add_new_summoner(pos : Vector2, qual : int):
	match qual:
		0 :
			add_alert(pos, Color.WHITE_SMOKE, 'Sum Sum Summoner!', 1.0)
			AudioManager.play(1)
		1 :
			add_alert(pos, Color.PALE_GOLDENROD, 'Nice!', 1.0)
			curr_combo = 0
			AudioManager.play(1)
		2 :
			add_alert(pos, Color.PALE_GREEN, 'Great!', 1.0)
			curr_combo += 1
			AudioManager.play(0)
		3 :
			add_alert(pos, Color.PALE_TURQUOISE, 'Excellent!', 1.5)
			curr_combo += 3
			AudioManager.play(0)

	set_zoom(qual)
	if curr_combo >= max_combo:
		max_combo = curr_combo

	if current_summoner:
		current_summoner.portal.stop_portal()

	var s = summSCN.instantiate()
	summoners.add_child(s)
	current_summoner = s

	current_summoner.portal.failed.connect(failed)

	current_summoner.global_position = pos
	remote_tr.global_position = current_summoner.portal_position.global_position
	summoner_list.append(current_summoner)

	if summoner_list.size() > max_summoners:
		var s_to_delete : Summoner = summoner_list.pop_front()
		s_to_delete.destroy()

	if qual != 0:
		summon_score += 1
		points += curr_combo*qual +1
	gui.update_labels(points, summon_score, curr_combo)

func set_zoom(q):
	var zoom_factor : float = 0.05

	match q:
		1 : zoom = 0.8
		2 : zoom -= zoom_factor
		3 : zoom -= zoom_factor

	if zoom <= min_zoom:
		zoom = min_zoom
	elif zoom >= max_zoom:
		zoom = max_zoom
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(camera_2d, 'zoom', Vector2(zoom, zoom), 0.3)


func failed():
	AudioManager.play(2)
	AudioManager.explosion()
	is_game_over = true
	add_alert(current_summoner.global_position, Color.PALE_VIOLET_RED, 'Noooo!', 2.0)
	gui.game_over(points, summon_score, max_combo)

	var tween : Tween = get_tree().create_tween()
	tween.tween_property(camera_2d, 'zoom', Vector2(0.3, 0.3), 1.0)

	await get_tree().create_timer(1.0).timeout
	can_reload = true
