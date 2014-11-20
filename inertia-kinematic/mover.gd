
extends Area2D

const SPEED = 200
const DIRECTION = Vector2(0, -1)

var velocity_index = null


func get_direction():
	var directoin = DIRECTION * get_scale()
	directoin = directoin.rotated(get_rot())
	return directoin


func _on_self_body_enter(body):
	if body.has_meta("who") and body.get_meta("who") == "player":
		if velocity_index == null:
			velocity_index = body.append_external_velocity(get_direction() * SPEED)


func _on_self_body_exit(body):
	if body.has_meta("who") and body.get_meta("who") == "player":
		if velocity_index != null:
			body.remove_external_velocity(velocity_index)
			velocity_index = null


func _ready():
	self.connect("body_enter", self, "_on_self_body_enter")
	self.connect("body_exit", self, "_on_self_body_exit")
