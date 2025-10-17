class_name ScrollRightUIElement;
extends Control;

var origin_position: Vector2;
@export var reset_after_x_position_reached: float = 0.0;
@export var scroll_speed = 100;

func _ready() -> void:
	origin_position = position;

func _physics_process(delta: float) -> void:
	position.x += scroll_speed * delta;
	if position.x >= reset_after_x_position_reached:
		position.x = origin_position.x;
