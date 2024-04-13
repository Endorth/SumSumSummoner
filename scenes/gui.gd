extends Control

@onready var summons_label = $SummonsLabel
@onready var combo_label = $ComboLabel
@onready var points_label = $PointsLabel

func _ready():
	$GameOverPanel.visible = false

func update_labels(p, s, cc):
	points_label.text = 'points -> ' + str(p)
	summons_label.text = 'sum sum summons -> ' + str(s)
	combo_label.text = 'combo -> ' + str(cc)

func game_over(p, s, mc):
	summons_label.visible = false
	combo_label.visible = false
	points_label.visible = false

	$GameOverPanel.visible = true
	$GameOverPanel/MaxComboLabel.text = 'max combo -> ' + str(mc)
	$GameOverPanel/GOSummonsLabel.text = 'sum sum summons -> ' + str(s)
	$GameOverPanel/GOPointsLabel.text = 'summon points -> ' + str(p)
