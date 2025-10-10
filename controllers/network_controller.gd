class_name NetworkController;
extends Node;

static var peer: ENetMultiplayerPeer;
static var instance: NetworkController;

func _ready()->void:
	instance = self;

func start_server()->void:
	peer = ENetMultiplayerPeer.new();
	var res = peer.create_server(7127);
	get_tree().get_multiplayer().multiplayer_peer = peer;
	get_tree().get_multiplayer().peer_connected.connect(NetworkPlayersController.instance.spawn_player);

func start_client()->void:
	peer = ENetMultiplayerPeer.new();
	var res = peer.create_client("127.0.0.1", 7127);
	get_tree().get_multiplayer().multiplayer_peer = peer;
