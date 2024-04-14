extends Control

var LPANSCN = preload("res://scenes/leader_board_panel.tscn")
# Called when the node enters the scene tree for the first time.

var is_naming : bool = false
var is_ready : bool = false
func _ready():
	$NameCheckLabel.text = 'Welcome, ' + Init.player_name
	Init.lead_score_ready.connect(update_leaderboard)
	Init.read_score()

func _input(_event):
	if Input.is_action_just_pressed('ui_accept'):
		_on_save_pressed()
		_on_text_edit_focus_exited()
	if Input.is_action_just_pressed('ui_select'):
		if not is_naming and is_ready:
			_on_save_pressed()
			AudioManager.play(0)
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scenes/world.tscn")

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
