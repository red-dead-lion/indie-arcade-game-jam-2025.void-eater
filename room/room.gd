class_name Room;
extends Node2D

@export var top_wall: Node;
@export var bottom_wall: Node;
@export var left_wall: Node;
@export var right_wall: Node;

var suck_up_timer = 1.0;
@export var c_suck_up_timer = 0.0;
var alarm_timer = 5.0;
@export var c_alarm_timer = 0.0;

var is_alarming_tiles = false;

@export var removed_walls: Array = [];

func _enter_tree() -> void:
	set_multiplayer_authority(1, true);

func _physics_process(delta: float) -> void:
	if !get_tree().get_multiplayer().is_server():
		return;
	if is_alarming_tiles:
		c_alarm_timer += delta;
	if c_alarm_timer > alarm_timer:
		c_suck_up_timer += delta;
		rotation += delta * 5;
		if c_suck_up_timer > suck_up_timer:
			queue_free();
		scale = lerp(Vector2.ONE, Vector2.ZERO, c_suck_up_timer / suck_up_timer);

func remove_wall(direction: Main.CardinalDirection)->void:
	if !removed_walls.has(direction):
		removed_walls.append(direction);
	match direction:
		Main.CardinalDirection.Up:
			for c in top_wall.get_children():
				top_wall.remove_child(c);
		Main.CardinalDirection.Down:
			for c in bottom_wall.get_children():
				bottom_wall.remove_child(c);
		Main.CardinalDirection.Left:
			for c in left_wall.get_children():
				left_wall.remove_child(c);
		Main.CardinalDirection.Right:
			for c in right_wall.get_children():
				right_wall.remove_child(c);

func destroy_room()->void:
	is_alarming_tiles = true;
	for wall in get_children():
		for tile in wall.get_children():
			if tile is Tile:
				tile.begin_alert();

func _on_multiplayer_synchronizer_synchronized() -> void:
	for w in removed_walls:
		remove_wall(w);
