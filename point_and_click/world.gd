
extends Node2D

var tile_map = null
var obstacle_tile_id = null
var pointer = null


func _get_cell_center_offset():
	return tile_map.get_cell_size() / 2


func _get_cell_coord_by_pos(pos):
	var result = (pos - tile_map.get_pos() - _get_cell_center_offset()) / tile_map.get_cell_size()
	return Vector2(round(result.x), round(result.y))


func _get_cell_by_coord(coord):
	return tile_map.get_cell(coord.x, coord.y)


func _get_cell_pos(coord):
	var result = (Vector2(1, 1) + coord) * tile_map.get_cell_size()
	return result + tile_map.get_pos() - _get_cell_center_offset()


func _fixed_process(delta):
	if (Input.is_action_pressed("restart")):
		var global = get_node("/root/global")
		global.goto_scene("res://world.scn.xml")
	if pointer.obstacle_quantity > 0:
		var mouse_pos = Input.get_mouse_pos()
		var pointed_cell_coord = _get_cell_coord_by_pos(mouse_pos)
		var pointed_cell = _get_cell_by_coord(pointed_cell_coord)
		if pointed_cell == -1:
			pointer.set_pos(_get_cell_pos(pointed_cell_coord))
			pointer.show()
			if Input.is_action_pressed("point_and_click"):
				var x = pointed_cell_coord.x
				var y = pointed_cell_coord.y
				tile_map.set_cell(x, y, obstacle_tile_id)
				pointer.obstacle_quantity -= 1
				pointer.redraw_label()
				pointer.hide()
				get_node("help_label").hide()
		else:
			pointer.hide()


func _on_finish_body_enter(body):
    get_node("win_label").show()


func _ready():
	pointer = get_node("pointer")
	tile_map = get_node("tile_map")
	get_node("finish").connect("body_enter", self, "_on_finish_body_enter")
	var tile_set = tile_map.get_tileset()
	obstacle_tile_id = tile_set.find_tile_by_name("obstacle")
	set_fixed_process(true)
	get_node("Path2D").show()
