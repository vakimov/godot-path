
extends Node2D


func _ready():
	pass


func _on_finish_1_body_enter(body):
	get_node("heart_part 1").show()
	get_node("finish 1").hide()


func _on_finish_2_body_enter(body):
	get_node("heart_part 2").show()
	get_node("finish 2").hide()


func _on_finish_3_body_enter(body):
	get_node("heart_part 3").show()
	get_node("finish 3").hide()
