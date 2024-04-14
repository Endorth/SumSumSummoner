extends Node2D

class_name Summoner
@onready var pivot = $Pivot
@onready var portal_position = $Pivot/PortalPosition

@onready var portal : Portal = $Portal
@onready var anim = $AnimationPlayer


func _ready():
	set_color()
	pivot.rotation_degrees = randi_range(15, 165)
	portal.global_position = portal_position.global_position

func dead():
	anim.play('dead')

func set_color():
	var r = randf_range(0.1, 0.5)
	var g = randf_range(0.1, 0.5)
	var b = randf_range(0.1, 0.5)
	$Sprite2D.modulate = Color(r,g,b)
func destroy():
	get_parent().remove_child(self)
	queue_free()
