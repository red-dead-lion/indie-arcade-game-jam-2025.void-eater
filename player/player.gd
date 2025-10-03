class_name Player;
extends CharacterBody2D;

# Settings
var movement_speed = 500;
var jump_speed = 1500;

func _physics_process(delta: float) -> void:
	var movement_impetus = Vector2.ZERO;
	print(velocity.x);
	if Input.is_action_pressed("ui_left") and velocity.x > -movement_speed:
		$Sprite2D.scale.x = -1;
		movement_impetus += Vector2.LEFT * movement_speed;
	if Input.is_action_pressed("ui_right")and velocity.x < movement_speed:
		$Sprite2D.scale.x = 1;
		movement_impetus += Vector2.RIGHT * movement_speed;
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		movement_impetus -= Vector2(velocity.x * 0.2, 0);
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()):
		velocity += Vector2.UP * jump_speed
	velocity += get_gravity() + movement_impetus;
	velocity.x = clamp(velocity.x, -movement_speed, movement_speed);
	velocity.y = clamp(velocity.y, -9999, jump_speed);
	move_and_slide();
