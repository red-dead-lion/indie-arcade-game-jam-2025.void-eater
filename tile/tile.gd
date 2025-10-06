class_name Tile;
extends StaticBody2D

var is_on_alert = false;

func begin_alert()->void:
	$AlertToBeDestroyedTimer.start();

func _on_alert_to_be_destroyed_timer_timeout() -> void:
	$AlertToBeDestroyedTimer.wait_time = $AlertToBeDestroyedTimer.wait_time * 0.9
	is_on_alert = !is_on_alert;
	if $AlertToBeDestroyedTimer.wait_time < 0.05 or is_on_alert:
		$Sprite2D.modulate = Color(1.0, 0.0, 0.0);
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0);
	
