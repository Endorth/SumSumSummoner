extends Node

var player_name : String = "summoner's sect"
func _ready():
	SilentWolf.configure({
		'api_key': secrets.api_key,
		'game_id': secrets.game_id,
		'log_level': 0,
		})

var lead_scores : Array

signal lead_score_ready

func read_score():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(100).sw_get_scores_complete
	lead_scores = sw_result.scores
	lead_score_ready.emit()
