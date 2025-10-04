class_name Room;
extends Node2D

@export var top_wall: Node2D;
@export var bottom_wall: Node2D;
@export var left_wall: Node2D;
@export var right_wall: Node2D;

var suck_up_timer = 1.0;
var c_suck_up_timer = 0.0;

var is_being_sucked_up = false;

func _physics_process(delta: float) -> void:
	if is_being_sucked_up:
		c_suck_up_timer += delta;
		rotation += delta * 5;
		if c_suck_up_timer > suck_up_timer:
			queue_free();
		scale = lerp(Vector2.ONE, Vector2.ZERO, c_suck_up_timer / suck_up_timer);

func toggle_wall(direction: Main.CardinalDirection)->void:
	match direction:
		Main.CardinalDirection.Up:
			remove_child(top_wall);
		Main.CardinalDirection.Down:
			remove_child(bottom_wall);
		Main.CardinalDirection.Left:
			remove_child(left_wall);
		Main.CardinalDirection.Right:
			remove_child(right_wall);
	
func destroy_room()->void:
	is_being_sucked_up = true;
