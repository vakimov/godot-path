
extends Node2D


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if (Input.is_action_pressed("restart")):
		var global = get_node("/root/global")
		global.goto_scene("res://world.scn.xml")


func _on_finish_body_enter( body ):
	remove_child(get_node("finish 1"))


func _on_finish_2_body_enter( body ):
	remove_child(get_node("finish 2"))
