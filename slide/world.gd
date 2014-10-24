
extends Node2D


func _fixed_process(delta):
	if (Input.is_action_pressed("restart")):
		var global = get_node("/root/global")
		global.goto_scene("res://world.scn.xml")


func _on_enemy_body_enter( body ):
	get_node("youlost").show()
	get_node("restart").show()


func _on_finish_body_enter( body ):
	get_node("youwin").show()


func _ready():
	get_node("finish").connect("body_enter", self, "_on_finish_body_enter")
	get_node("enemy").connect("body_enter", self, "_on_enemy_body_enter")
	set_fixed_process(true)
