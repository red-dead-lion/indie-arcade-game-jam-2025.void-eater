class_name ItemBoxSpawnTimer;
extends Timer

# Settings
@export var box_scene: PackedScene;
@export var boxes_root: Node;
@export var rooms_root: Node;

# Triggers
func _on_timeout() -> void:
	if !multiplayer.is_server() or rooms_root.get_child_count() == 0:
		return;
	var box = box_scene.instantiate();
	boxes_root.add_child(box, true);
	var room = rooms_root.get_child(randi() % rooms_root.get_child_count());
	if room is Room:
		box.position = room.position;
