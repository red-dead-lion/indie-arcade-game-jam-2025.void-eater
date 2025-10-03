class_name Room;
extends Node2D

@export var top_wall: Node2D;
@export var bottom_wall: Node2D;
@export var left_wall: Node2D;
@export var right_wall: Node2D;

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
	
