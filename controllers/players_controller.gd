class_name NetworkPlayersController;
extends MultiplayerSpawner

@export var player_scene: PackedScene;
@export var rooms_root: Node;
static var instance: NetworkPlayersController;

func _ready()->void:
	instance = self;
	
func spawn_player(id: int)->void:
	if !get_tree().get_multiplayer().is_server():
		return;
	var player = player_scene.instantiate();
	player.name = str(id);
	get_node(spawn_path).add_child(player, true);
	player.remote_update_position.rpc(
		rooms_root.get_child(
			randi() % rooms_root.get_child_count()
		).global_position
	);
