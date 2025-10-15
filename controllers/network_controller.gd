class_name NetworkController;
extends Node;

static var instance: NetworkController;
var clients_required: int = 2;

func _enter_tree() -> void:
	set_multiplayer_authority(1);

func _ready()->void:
	instance = self;

func start_server()->bool:
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_server(
		int($"/root/Game/UI/ConnectUI/Settings/PortContainer/TextEdit".text)
	);
	if error != OK:
		$"/root/Game/UI/ConnectUI/Settings/ConnectionFeedback".text = (
			"Unable to create server (" + error_string(error) + ")"
		);
		return false;
	get_tree().get_multiplayer().multiplayer_peer = peer;
	get_tree().get_multiplayer().peer_connected.connect(func (_id)->void:
		if (
			NetworkController.instance.clients_required ==
				get_tree().get_multiplayer().get_peers().size() + 1
			and get_tree().get_multiplayer().is_server()
		):
			Main.instance.create_level_from_properties();
			NetworkPlayersController.instance.spawn_player(1);
			for n in get_tree().get_multiplayer().get_peers():
				NetworkPlayersController.instance.spawn_player(n);
			hide_lobby_ui.rpc();
	);
	return true;

func start_client()->bool:
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(
		$"/root/Game/UI/ConnectUI/Settings/IpAddrContainer/TextEdit".text,
		str_to_var(
			$"/root/Game/UI/ConnectUI/Settings/PortContainer/TextEdit".text
		)
	);
	if error != OK:
		$"/root/Game/UI/ConnectUI/Settings/ConnectionFeedback".text = (
			"Unable to join server (" + error_string(error) + ")"
		);
		return false;
	get_tree().get_multiplayer().multiplayer_peer = peer;
	return true;

@rpc('any_peer', 'call_local')
func hide_lobby_ui()->void:
	$"/root/Game/UI/ConnectUI".visible = false;

@rpc('any_peer')
func cancel_connection()->void:
	if multiplayer.get_remote_sender_id() == 1:
		for n in get_tree().get_multiplayer().get_peers():
			get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(n);
		get_tree().get_multiplayer().multiplayer_peer.close();
	else:
		get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(
			multiplayer.get_remote_sender_id()
		);
