
extends KinematicBody2D

const SPEED_TO_BREAK = 190

var player = null


func _fixed_process(delta):
	# The code below should work, but it doesn't
	if is_colliding():
		var v = get_collider_velocity()
		var l = v.length()
		if get_collider_velocity().length() > SPEED_TO_BREAK:
			get_parent().remove_child(self)
	# So I wrote this workaround instead
	if player.is_colliding() and player.get_collider() == self:
		#var v = player.velocity.length()
		#var pv = player.prev_velocity.length()
		#var ppv = player.prev_prev_velocity
		if player.velocity.length() > SPEED_TO_BREAK:
			get_node("/root/world/sound").play("broke_glass")
			get_parent().remove_child(self)


func _ready():
	player = get_node("/root/world/player")
	set_fixed_process(true)


func _on_Area2D_body_enter( body ):
	if body.has_meta("who") and body.get_meta("who") == "player":
		var player = body
		if player.velocity.length() > SPEED_TO_BREAK:
			get_parent().remove_child(self)
