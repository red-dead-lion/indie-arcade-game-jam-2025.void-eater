class_name NetworkController;
extends Node;

# Static
static var instance: NetworkController;

# Settings
@export var players_root_node: Node;
@export var rooms_root_node: Node;

# Properties
var clients_required: int = 2;

# Lifecycle
func _ready()->void:
	instance = self;

# Methods
func start_server()->bool:
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_server(
		LobbyUIController.instance.port
	);
	if error != OK:
		LobbyUIController.instance.feedback_message = (
			"Unable to create server (" + error_string(error) + ")"
		);
		return false;
	multiplayer.multiplayer_peer = peer;
	multiplayer.peer_connected.connect(func (_id)->void:
		if (
			NetworkController.instance.clients_required ==
				multiplayer.get_peers().size() + 1
			and multiplayer.is_server()
		):
			Main.instance.create_level_from_properties();
			Player._create_instance(Main.SERVER_ID, players_root_node, rooms_root_node);
			for n in multiplayer.get_peers():
				Player._create_instance(n, players_root_node, rooms_root_node);
			LobbyUIController.instance.RPC_hide_lobby_ui.rpc();
			GameUIController.instance.RPC_show_game_ui.rpc();
	);
	return true;

func start_client()->bool:
	var peer = ENetMultiplayerPeer.new();
	var error: Error = peer.create_client(
		LobbyUIController.instance.address,
		LobbyUIController.instance.port
	);
	if error != OK:
		LobbyUIController.instance.feedback_message = (
			"Unable to create server (" + error_string(error) + ")"
		);
		return false;
	multiplayer.multiplayer_peer = peer;
	return true;

# Networking
@rpc('any_peer', 'call_local')
func RPC_cancel_connection()->void:
	if multiplayer.get_remote_sender_id() == Main.SERVER_ID:
		for n in multiplayer.get_peers():
			multiplayer.multiplayer_peer.disconnect_peer(n);
		multiplayer.multiplayer_peer.close();
		multiplayer.multiplayer_peer = null
	else:
		multiplayer.multiplayer_peer.disconnect_peer.call_deferred(
			multiplayer.get_remote_sender_id(),
		);
