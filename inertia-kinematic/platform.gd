
extends KinematicBody2D

var _anim_finished = true


func _on_anim_finished():
	_anim_finished = true


func _stop_player():
	if _anim_finished:
		get_node("anim").play("stop_player")
		_anim_finished = false


func _ready():
	get_node("anim").connect("finished", self, "_on_anim_finished")
