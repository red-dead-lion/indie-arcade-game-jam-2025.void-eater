class_name Rooms;
extends MultiplayerSpawner;

# Timers
var destroy_room_timer = 6.0;
var c_destroy_room_timer = 0.0;

# Lifecycle
func _process(delta: float) -> void:
	c_destroy_room_timer += delta;
	if c_destroy_room_timer > destroy_room_timer and get_child_count() > 0:
		var room: Room = get_children()[randi() % get_child_count()];
		room.destroy_room();
		c_destroy_room_timer = 0;
