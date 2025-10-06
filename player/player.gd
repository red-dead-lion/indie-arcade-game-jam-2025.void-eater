class_name Player;
extends CharacterBody2D;

# Settings
var movement_speed = 500;
var jump_speed = 1500;
var wall_jump_impetus = 1000;

# Timers
var walljump_lr_fromdir: Vector2;
var walljump_lr_movement_forgiveness_timer = 0.1;
var c_walljump_lr_movement_forgiveness_timer = 0;

# Lifecycle
func _physics_process(delta: float) -> void:
	var movement_impetus = Vector2.ZERO;
	rotation = 0;
	c_walljump_lr_movement_forgiveness_timer -= delta;
	if  Input.is_action_pressed("ui_left") and is_on_wall_only() and !$RayCast2D.is_colliding() and $Sprite2D.scale.x == -1:
			rotation = -PI / 4;
			velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 8);
			if Input.is_action_just_pressed("ui_accept"):
				movement_impetus.x += wall_jump_impetus;
				c_walljump_lr_movement_forgiveness_timer = walljump_lr_movement_forgiveness_timer;
				walljump_lr_fromdir = Vector2.LEFT;
	if Input.is_action_pressed("ui_left") and velocity.x > -movement_speed and !(walljump_lr_fromdir == Vector2.LEFT and c_walljump_lr_movement_forgiveness_timer > 0):
		$Sprite2D.scale.x = -1;
		movement_impetus += Vector2.LEFT * movement_speed;
	if Input.is_action_pressed("ui_right") and is_on_wall_only() and !$RayCast2D.is_colliding() and $Sprite2D.scale.x == 1:
			rotation = PI / 4;
			velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 8);
			if Input.is_action_just_pressed("ui_accept"):
				movement_impetus.x -= wall_jump_impetus;
				c_walljump_lr_movement_forgiveness_timer = walljump_lr_movement_forgiveness_timer;
				walljump_lr_fromdir = Vector2.RIGHT;
	if Input.is_action_pressed("ui_right") and velocity.x < movement_speed and !(walljump_lr_fromdir == Vector2.RIGHT and c_walljump_lr_movement_forgiveness_timer > 0):
		$Sprite2D.scale.x = 1;
		movement_impetus += Vector2.RIGHT * movement_speed;
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		movement_impetus -= Vector2(velocity.x * 0.2, 0);
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()):
		velocity += Vector2.UP * jump_speed
	velocity += get_gravity() + movement_impetus;
	velocity.x = clamp(velocity.x, -movement_speed, movement_speed);
	velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 2);
	move_and_slide();
