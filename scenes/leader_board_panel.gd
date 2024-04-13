extends Panel

@onready var name_label = $NameLabel
@onready var pos_label = $PosLabel
@onready var points_label = $PointsLabel

func set_panel(ps, nm, sc):
	name_label.text = str(nm)
	pos_label.text = str(ps)
	points_label.text = str(sc)
