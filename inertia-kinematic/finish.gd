
extends Area2D


func _on_self_body_enter(body):
	if body.has_meta("who") and body.get_meta("who") == "player":
		get_parent().remove_child(self)


func _ready():
	connect("body_enter", self, "_on_self_body_enter")
