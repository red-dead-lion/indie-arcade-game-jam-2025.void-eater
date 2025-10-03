class_name Player;
extends CharacterBody2D;

# Settings
var movement_speed = 250;
var jump_speed = 1250;

func _physics_process(delta: float) -> void:
	var movement_impetus = Vector2.ZERO;
	if Input.is_action_pressed("ui_left") and velocity.x > -movement_speed:
		movement_impetus += Vector2.LEFT * movement_speed;
	if Input.is_action_pressed("ui_right")and velocity.x < movement_speed:
		movement_impetus += Vector2.RIGHT * movement_speed;
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		movement_impetus -= Vector2(velocity.x * 0.2, 0);
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity += Vector2.UP * jump_speed
	velocity += get_gravity() + movement_impetus;
	move_and_slide();
