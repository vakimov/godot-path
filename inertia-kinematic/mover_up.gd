
extends Node2D


func _on_body_enter(body):
	get_node("anim").stop("run")


func _ready():
	get_node("chain_up 1").connect("body_enter", self, "_on_body_enter")
	get_node("chain_up 2").connect("body_enter", self, "_on_body_enter")
	pass


func _on_chain_up_1_body_enter( body ):
	get_node("anim").stop("run")


func _on_chain_up_2_body_enter( body ):
	get_node("anim").stop("run")
