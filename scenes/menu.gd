extends Control

var alertSCN = preload("res://scenes/alert.tscn")
var LPANSCN = preload("res://scenes/leader_board_panel.tscn")
# Called when the node enters the scene tree for the first time.
@onready var dialogue_label = $Dialogue/DialogueLabel

var is_naming : bool = false
var is_ready : bool = false
var can_press : bool= false

var text_idx : int = 0
var texts : Array[String] = [
	'try not to materialize the summoners on top of things!',
	'summon the maximum number of summoners!',
	'beware of the deadly poison gas of darkness and destructive death!',
	"don't break the chain!",
	'do not rush, invoke at the right time!',
	'if you take too long, you will break the chain!',
	'the more you adjust the summon, the more points you get!',
	'use the mouse to redirect the portal!',
	'if you like it, follow me on twitter and itch.io! <3',
	'...',
]
func _ready():
	randomize()
	$Dialogue.visible = false
	texts.shuffle()
	$AnimatedSprite2D4.visible = false
	$NameCheckLabel.text = 'Welcome, ' + Init.player_name
	Init.lead_score_ready.connect(update_leaderboard)
	Init.read_score()

func _input(_event):
	if Input.is_action_just_pressed('ui_accept'):
		_on_save_pressed()
		_on_text_edit_focus_exited()
	if Input.is_action_just_pressed('ui_select'):
		if not is_naming and is_ready:
			if can_press:
				add_alert($Sprite2D.global_position, Color.PALE_TURQUOISE, 'Summoner!', 1.0)
				_on_save_pressed()
				AudioManager.play(0)
				$AnimatedSprite2D4.visible = true
				$AnimatedSprite2D4.play()
			else:
				add_alert($Sprite2D.global_position, Color.PALE_VIOLET_RED, 'nope!', 1.0)
			#await get_tree().create_timer(0.5).timeout

func add_alert(pos, col : Color, txt : String, size : float):
	var a = alertSCN.instantiate()
	add_child(a)
	a.global_position = pos
	a.set_alert(col, txt, size)

func set_can_not_press():
	can_press = false
func set_can_press():
	can_press = true

func update_leaderboard():
	for l in %LeaderboardCont.get_children():
		%LeaderboardCont.remove_child(l)
	var n_sc : int = Init.lead_scores.size()
	for i in n_sc:
		add_lead_panel(i+1, Init.lead_scores[i]['player_name'], Init.lead_scores[i]['score'])
	is_ready = true

func add_lead_panel(ps, nm, sc):
	var lPan = LPANSCN.instantiate()
	%LeaderboardCont.add_child(lPan)
	lPan.set_panel(ps, nm, sc)


func _on_button_pressed():
	for l in %LeaderboardCont.get_children():
		%LeaderboardCont.remove_child(l)
	Init.read_score()


func _on_save_pressed():
	var p_name :String = str($TextEdit.text)
	if p_name:
		Init.player_name = str(p_name)
		$NameCheckLabel.text = 'Welcome, ' + Init.player_name


func _on_text_edit_focus_entered():
	is_naming = true

func _on_text_edit_focus_exited():
	is_naming = false

func _on_music_h_slider_value_changed(value):
	var v = value/100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), linear_to_db(v))
func _on_sfxh_slider_value_changed(value):
	var v = value/100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('SFX'), linear_to_db(v))
func _on_master_h_slider_value_changed(value):
	var v = value/100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), linear_to_db(v))


func _on_animated_sprite_2d_4_animation_finished():
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_timer_timeout():
	is_ready = true
	update_leaderboard()



func _on_dialogue_timer_timeout():
	dialogue_label.text = texts[text_idx]
	$Dialogue.visible = true
	text_idx += 1
	if text_idx >= texts.size():
		text_idx = 0
	await get_tree().create_timer(5.0).timeout
	$Dialogue.visible = false
	$DialogueTimer.start()
