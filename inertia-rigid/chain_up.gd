
extends Area2D

const SPEED = 60

var velocity_index = null


func _on_self_body_enter(body):
	if body.has_meta("who") and body.get_meta("who") == "player":
		#get_node("anim").stop()
		velocity_index = body.append_external_velocity(Vector2(0, -1) * SPEED)


func _on_self_body_exit(body):
	if body.has_meta("who") and body.get_meta("who") == "player":
		#get_node("anim").play("run")
		body.remove_external_velocity(velocity_index)


func _ready():
	self.connect("body_enter", self, "_on_self_body_enter")
	self.connect("body_exit", self, "_on_self_body_exit")
	get_node("anim").play("run")
