extends Timer

var is_started = false;
@export var box_scene: PackedScene;
@export var boxes_root: Node;
@export var rooms_root: Node;

func _enter_tree() -> void:
	get_tree().get_multiplayer().peer_connected.connect(func(id)->void:
		if !get_tree().get_multiplayer().is_server() and !is_started:
			return;
		start();
	);

func _on_timeout() -> void:
	if !get_tree().get_multiplayer().is_server():
		return;
	var box = box_scene.instantiate();
	boxes_root.add_child(box, true);
	var room = rooms_root.get_child(randi() % rooms_root.get_child_count());
	if room is Room:
		box.position = room.position;
			
