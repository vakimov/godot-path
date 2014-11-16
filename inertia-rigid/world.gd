
extends Node

var finish = null


func _fixed_process(delta):
	if Input.is_action_pressed("restart"):
		var global = get_node("/root/global")
		global.goto_scene("res://world.scn.xml")


func _on_finish_body_enter(body):
	finish.hide()


func _ready():
	set_fixed_process(true)
	finish = get_node("finish")
	finish.connect("body_enter", self, "_on_finish_body_enter")
