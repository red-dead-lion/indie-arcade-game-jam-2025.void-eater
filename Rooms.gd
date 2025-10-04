class_name Rooms;
extends Node2D;

var destroy_room_timer = 2.0;
var c_destroy_room_timer = 0.0;

func _process(delta: float) -> void:
	c_destroy_room_timer += delta;
	if c_destroy_room_timer > destroy_room_timer:
		var room: Room = get_children()[randi() % get_child_count()];
		room.destroy_room();
		c_destroy_room_timer = 0;
		print('pop');
