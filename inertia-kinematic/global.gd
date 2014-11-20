
extends Node

var current_scene = null


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(scene):
	# remove current scene from root and enqueue it for deletion
	var root = get_tree().get_root()
	root.remove_child(current_scene)
	current_scene.queue_free()
	
	# load and add new scene to root
	var s = ResourceLoader.load(scene)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
