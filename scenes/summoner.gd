extends Node2D

class_name Summoner
@onready var pivot = $Pivot
@onready var portal_position = $Pivot/PortalPosition

@onready var portal : Portal = $Portal

func _ready():
	pivot.rotation_degrees = randi_range(0, 180)
	portal.global_position = portal_position.global_position

func destroy():
	get_parent().remove_child(self)
	queue_free()
