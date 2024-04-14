extends Control

@onready var summons_label = $SummonsLabel
@onready var combo_label = $ComboLabel
@onready var points_label = $PointsLabel

func _ready():
	$GameOverPanel.visible = false

func update_labels(p, s, cc):
	points_label.text = str(p)
	summons_label.text = 'sum sum summons -> ' + str(s)
	combo_label.text = 'x ' + str(cc)

func game_over(p, s, mc):

	summons_label.visible = false
	combo_label.visible = false
	points_label.visible = false

	$GameOverPanel.visible = true
	$GameOverPanel/MaxComboLabel.text = 'max combo -> ' + str(mc)
	$GameOverPanel/GOSummonsLabel.text = 'sum sum summons -> ' + str(s)
	$GameOverPanel/GOPointsLabel.text = 'summon points -> ' + str(p)
	if p > 0:
		check_score(p)

func check_score(points):
	var sw_result = await SilentWolf.Scores.get_top_score_by_player(Init.player_name).sw_top_player_score_complete
	if sw_result.size() < 3:
		save_score(points)
	else:
		var top_score = sw_result['top_score']['score']
		if points > top_score:
			save_score(points)
		#else:
			#print('has not been achieved')
	#print("Does player have a top score? " + str(!sw_result['top_score'].empty()))

func save_score(points):
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(Init.player_name, points).sw_save_score_complete
	#print("Score persisted successfully: " + str(sw_result.score_id))
	Init.read_score()
