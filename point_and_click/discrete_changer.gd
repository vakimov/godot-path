
extends Area2D


func get_steps_number():
	return 1


func _ready():
	var steps_number = str(get_steps_number())
	get_node("label").set_text(steps_number)


func _on_discrete_changer_body_enter( body ):
	body.next_steps_in_run = get_steps_number()
