
extends Area2D


func _on_self_body_enter(body):
	var name = get_name()
	var n = name.substr(name.length()-1, name.length())
	get_node("/root/world/platform " + n)._stop_player()


func _ready():
	self.connect("body_enter", self, "_on_self_body_enter")
	pass
