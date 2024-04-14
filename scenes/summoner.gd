extends Node2D

class_name Summoner
@onready var pivot = $Pivot
@onready var portal_position = $Pivot/PortalPosition
@onready var sprite = $Sprite2D

@onready var portal : Portal = $Portal
@onready var anim = $AnimationPlayer
@export var no_sounds_array : Array[AudioStreamMP3] = []
@onready var sfx = $sfx

signal add_corpse
signal im_dead
func _ready():
	set_color()
	pivot.rotation_degrees = randi_range(15, 165)
	portal.global_position = portal_position.global_position


func dead():
	anim.play('dead')
	var s : AudioStreamMP3
	no_sounds_array.pick_random()
	sfx.stream = s
	var rp = randf_range(0.9, 1.2)
	sfx.pitch_scale = rp
	sfx.play()

func corpse():
	add_corpse.emit(self)

func set_color():
	var r = randf_range(0.1, 0.5)
	var g = randf_range(0.1, 0.5)
	var b = randf_range(0.1, 0.5)
	sprite.modulate = Color(r,g,b)
func destroy():
	get_parent().remove_child(self)
	queue_free()


func _on_area_2d_area_entered(area):
	im_dead.emit(self)
