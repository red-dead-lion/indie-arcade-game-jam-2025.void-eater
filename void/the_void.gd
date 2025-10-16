class_name TheVoid;
extends Area2D;

# Settings
@export var scale_increase_per_room_sucked_up = 0.1;

# Properties
var target_travel_position: Vector2;
var origin_position: Vector2;

# Timers
var move_to_target_timer = 4.0;
var c_move_to_target_timer = 4.0;

# Triggers
func _on_room_sucked_up(_room: Room):
	if !multiplayer.is_server():
		return;
	scale += Vector2.ONE * scale_increase_per_room_sucked_up;
	
func _on_room_alarm_started(room: Room):
	if !multiplayer.is_server():
		return;
	c_move_to_target_timer = 0;
	target_travel_position = room.global_position;
	origin_position = global_position;

# Lifecycle
func _ready()->void:
	global_position = (get_viewport_rect().get_center()
		+ Vector2.RIGHT * 396
		+ Vector2.DOWN * 272
	);
	target_travel_position = global_position;

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return;
	rotation += delta;
	if c_move_to_target_timer < move_to_target_timer:
		c_move_to_target_timer += delta;
		global_position = lerp(
			origin_position,
			target_travel_position,
			c_move_to_target_timer / move_to_target_timer
		);
	else:
		c_move_to_target_timer = move_to_target_timer;
		global_position = target_travel_position;
