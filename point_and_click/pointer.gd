
extends Node2D

var label = null
var obstacle_quantity = 2


func redraw_label():
	label.set_text(str(obstacle_quantity))


func _ready():
	label = get_node("label")
	redraw_label()
