class_name LobbyUIController
extends CenterContainer

func _ready()->void:
	get_tree().get_multiplayer().peer_connected.connect(func(_id)->void:
		update_lobby_waiting_for_players_label();
	);

func update_lobby_waiting_for_players_label()->void:
	$Waiting/Label.text = (
		"Waiting for players to connect... ("
			+ var_to_str(get_tree().get_multiplayer().get_peers().size() + 1)
			+ "/"
			+ var_to_str(NetworkController.instance.clients_required)
			+ ")"
	);

func _on_player_count_spin_box_value_changed(value: float) -> void:
	NetworkController.instance.clients_required = int(value)

func _on_host_button_down() -> void:
	if NetworkController.instance.start_server():
		$Settings.visible = false;
		$Waiting.visible = true;
		update_lobby_waiting_for_players_label();
	
func _on_join_button_down() -> void:
	if NetworkController.instance.start_client():
		$Settings.visible = false;
		$Waiting.visible = true;

func _on_cancel_button_button_down() -> void:
	NetworkController.instance.cancel_connection.rpc();
	$Settings.visible = true;
	$Waiting.visible = false;
