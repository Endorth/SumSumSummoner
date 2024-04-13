extends Node

@export var sum_sounds_array : Array[AudioStreamMP3] = []
@export var summoner_sounds_array : Array[AudioStreamMP3] = []
@export var no_sounds_array : Array[AudioStreamMP3] = []

@onready var sum_sfx = $SumSFX


func play(i):
	var s : AudioStreamMP3
	match i:
		0 : s = sum_sounds_array.pick_random()
		1 : s = summoner_sounds_array.pick_random()
		2 : s = no_sounds_array.pick_random()
	sum_sfx.stream = s
	var rp = randf_range(0.9, 1.2)
	sum_sfx.pitch_scale = rp
	sum_sfx.play()

func explosion():
	var rp = randf_range(0.9, 1.2)
	$Expl.pitch_scale = rp
	$Expl.play()
