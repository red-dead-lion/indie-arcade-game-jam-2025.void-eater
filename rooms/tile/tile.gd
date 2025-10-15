class_name Tile;
extends StaticBody2D

# Properties
var is_on_alert = false;

# Triggers
func _on_alert_to_be_destroyed_timer_timeout() -> void:
	if !multiplayer.is_server():
		return;
	$AlertToBeDestroyedTimer.wait_time = $AlertToBeDestroyedTimer.wait_time * 0.9
	is_on_alert = !is_on_alert;
	if $AlertToBeDestroyedTimer.wait_time < 0.05 or is_on_alert:
		$Sprite2D.modulate = Color(1.0, 0.0, 0.0);
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0);

# Lifecycle
func _enter_tree() -> void:
	set_multiplayer_authority(1, true);
	request_ready();
	reparent(get_parent());

# Methods
func begin_alert()->void:
	$AlertToBeDestroyedTimer.start();

# Networking
@rpc("call_local")
func remote_request_queue_free():
	queue_free();
