class_name LobbyUIController;
extends CenterContainer;

# Static
static var instance: LobbyUIController;

# Settings
@export var connection_feedback_label: Label;
@export var port_text_edit: TextEdit;
@export var address_text_edit: TextEdit;
@export var waiting_label: Label;
@export var settings_ui_container_node: Node;
@export var waiting_ui_container_node: Node;

# Properties
var feedback_message: String:
	set(new_feedback_message):
		connection_feedback_label.text = new_feedback_message;
var port: int:
	get():
		return int(port_text_edit.text)
var address: String:
	get():
		return address_text_edit.text

# Triggers
func _on_player_count_spin_box_value_changed(value: float) -> void:
	NetworkController.instance.clients_required = int(value)

func _on_host_button_down() -> void:
	if NetworkController.instance.start_server():
		settings_ui_container_node.visible = false;
		waiting_ui_container_node.visible = true;
		update_lobby_waiting_for_players_label();
	
func _on_join_button_down() -> void:
	if NetworkController.instance.start_client():
		settings_ui_container_node.visible = false;
		waiting_ui_container_node.visible = true;

func _on_cancel_button_button_down() -> void:
	NetworkController.instance.RPC_cancel_connection.rpc();
	settings_ui_container_node.visible = true;
	waiting_ui_container_node.visible = false;
	
# Lifecycle
func _ready()->void:
	instance = self;
	multiplayer.peer_connected.connect(func(_id)->void:
		update_lobby_waiting_for_players_label();
	);

# Methods
func update_lobby_waiting_for_players_label()->void:
	if multiplayer.get_peers().size() > NetworkController.instance.clients_required:
		waiting_label.text = (
			"Spectator Mode"
		);
	else:
		waiting_label.text = (
			"Waiting for players to connect... ("
				+ var_to_str(multiplayer.get_peers().size() + 1)
				+ "/"
				+ var_to_str(NetworkController.instance.clients_required)
				+ ")"
		);

# Networking
@rpc('any_peer', 'call_local')
func RPC_hide_lobby_ui()->void:
	visible = false;
