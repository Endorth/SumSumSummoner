extends Node2D


var corpseSCN = preload("res://scenes/corpse.tscn")
var summSCN = preload("res://scenes/summoner.tscn")
var alertSCN = preload("res://scenes/alert.tscn")
var poisonSCN = preload("res://scenes/poison.tscn")
@onready var gui = $CanvasLayer/GUI
@onready var summoners = $Summoners
@onready var remote_tr = $RemoteTr
@onready var camera_2d = $Camera2D
@onready var poison_populator = $RemoteTr/PoisonPopulator
@onready var poisons = $Poisons

var current_summoner : Summoner = null
var summoner_list : Array[Summoner] = []

var max_summoners : int = 250
var populator_list : Array = []
var summon_score : int = 0
var is_game_over : bool = false
var can_reload : bool = false
var curr_combo : int = 0
var max_combo : int = 0
var points : int = 0

var min_zoom : float = 0.4
var max_zoom : float = 1.0
var zoom = 1.0
var can_press = true
func _input(_event):
	if Input.is_action_just_pressed('ui_accept'):
		if is_game_over:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")

	if Input.is_action_just_pressed('ui_select'):
		play()
	if Input.is_action_just_pressed('mouse_left'):
		play()

func play():
	if can_press:
		can_press = false
		$CanPressTimer.start()
		assert(current_summoner, ' no has current summoner')
		if not is_game_over:
			if current_summoner.portal.can_press:
				if current_summoner.portal.is_perfect_summon:
					add_new_summoner(current_summoner.portal.global_position, 3, false)
				elif current_summoner.portal.is_great_summon:
					add_new_summoner(current_summoner.portal.global_position, 2, false)
				else:
					add_new_summoner(current_summoner.portal.global_position, 1, false)
			else:

				current_summoner.portal.anim.play("explosion")
				current_summoner.portal.stop_portal()
				failed()
		else:
			if can_reload:
				get_tree().reload_current_scene()

func _ready():
	for pop in poison_populator.get_children():
		populator_list.append(pop)
	add_new_summoner(Vector2.ZERO, 0,true)


func _process(delta):
	if not is_game_over and current_summoner:
		current_summoner.pivot.look_at(get_global_mouse_position())
		current_summoner.portal.global_position = current_summoner.portal_position.global_position
		clamp(current_summoner.pivot.rotation, 15, 165)

func add_alert(pos, col : Color, txt : String, size : float):
	var a = alertSCN.instantiate()
	add_child(a)
	a.global_position = pos
	a.set_alert(col, txt, size)

func add_new_summoner(pos : Vector2, qual : int, is_first_summoner : bool):
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

	current_summoner.add_corpse.connect(add_corpse)
	current_summoner.im_dead.connect(summoner_is_dead)
	current_summoner.portal.failed.connect(failed)

	current_summoner.global_position = pos
	remote_tr.global_position = current_summoner.global_position

	#current_summoner.portal.set_anim_speed(get_speed_by_points())
	current_summoner.portal.set_anim_speed(get_speed_by_combo())

	summoner_list.append(current_summoner)

	if is_first_summoner:
		current_summoner.portal.init(5.0)
	else:
		current_summoner.portal.init(randf_range(0.5, 1.0))

	if summoner_list.size() > max_summoners:
		var s_to_delete : Summoner = summoner_list.pop_front()
		s_to_delete.destroy()

	if qual != 0:
		summon_score += 1
		points += curr_combo*qual +1
	gui.update_labels(points, summon_score, curr_combo)

func summoner_is_dead(sum : Summoner):
	if current_summoner == sum:
		failed()
	sum.dead()

func get_speed_by_points() -> float:
	if points <= 100:
		return 0.5
	elif points > 100 and points <= 500:
		return 0.6
	elif points > 500 and points <= 700:
		return 0.7
	elif points > 800 and points <= 1000:
		return 0.85
	else:
		return 1.0

func get_speed_by_combo() -> float:
	if curr_combo <= 5:
		return 0.5
	elif curr_combo > 5 and curr_combo <= 10:
		return 0.6
	elif curr_combo > 10 and curr_combo <= 18:
		return 0.7
	elif curr_combo > 18 and curr_combo <= 25:
		return 0.85
	else:
		return 1.0


func add_corpse(sum : Summoner):
	var c = corpseSCN.instantiate()
	add_child(c)
	c.modulate = sum.sprite.modulate
	c.global_position = sum.global_position
	summoner_list.erase(sum)
	sum.destroy()

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

	$Timer.stop()
	AudioManager.play(2)
	AudioManager.explosion()
	is_game_over = true
	add_alert(current_summoner.global_position, Color.PALE_VIOLET_RED, 'Noooo!', 2.0)
	gui.game_over(points, summon_score, max_combo)

	var tween : Tween = get_tree().create_tween()
	tween.tween_property(camera_2d, 'zoom', Vector2(0.2, 0.2), 1.0)

	await get_tree().create_timer(1.0).timeout
	can_reload = true

func add_poison():
	var p = poisonSCN.instantiate()
	poisons.add_child(p)
	p.global_position = populator_list.pick_random().global_position

func _on_timer_timeout():
	add_poison()


func _on_can_press_timer_timeout():
	can_press = true


func _on_start_timer_timeout():
	add_alert(current_summoner.global_position, Color.WHITE_SMOKE, 'Summon!', 1.0)



func _on_ready_timer_timeout():
	add_alert(current_summoner.global_position, Color.WHITE_SMOKE, 'Ready?', 1.0)
	$StartTimer.start()
