class_name Player;
extends CharacterBody2D;

# Settings
var movement_speed = 500;
var jump_speed = 1500;
var wall_jump_impetus = 1000;

# Timers
var walljump_lr_fromdir: Vector2;
var walljump_stickiness_timer = 0.266;
var c_walljump_stickiness_timer = 0;

@rpc("any_peer", "call_local")
func remote_update_position(global_position: Vector2)->void:
	self.global_position = global_position;

func _enter_tree()->void:
	set_multiplayer_authority(name.to_int(), true);

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return;
	var movement_impetus = Vector2.ZERO;
	rotation = 0;
	if Input.is_action_pressed("ui_down") and is_on_wall(): 
		c_walljump_stickiness_timer = 0;
		if $Sprite2D.scale.x == -1:
			position = position + Vector2.RIGHT * 5;
		elif $Sprite2D.scale.x == 1:
			position = position + Vector2.LEFT * 5;
	if is_on_wall_only() and !$RayCast2D.is_colliding() and $Sprite2D.scale.x == -1:
		if Input.is_action_pressed("ui_left"):
			c_walljump_stickiness_timer = walljump_stickiness_timer;
		rotation = -PI / 4;
		velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 8.0);
		if Input.is_action_just_pressed("ui_accept"):
			movement_impetus.x += wall_jump_impetus;
			walljump_lr_fromdir = Vector2.LEFT;
	if Input.is_action_pressed("ui_left") and velocity.x > -movement_speed:
		c_walljump_stickiness_timer -= delta;
		if is_on_wall_only():
			if c_walljump_stickiness_timer <= 0:
				$Sprite2D.scale.x = -1;
				movement_impetus += Vector2.LEFT * movement_speed;
		else:
			$Sprite2D.scale.x = -1;
			movement_impetus += Vector2.LEFT * movement_speed;
	if is_on_wall_only() and !$RayCast2D.is_colliding() and $Sprite2D.scale.x == 1:
		if Input.is_action_pressed("ui_right"):
			c_walljump_stickiness_timer = walljump_stickiness_timer;
		rotation = PI / 4;
		velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 8.0);
		if Input.is_action_just_pressed("ui_accept"):
			movement_impetus.x -= wall_jump_impetus;
			walljump_lr_fromdir = Vector2.RIGHT;
	if Input.is_action_pressed("ui_right") and velocity.x < movement_speed:
		c_walljump_stickiness_timer -= delta;
		if is_on_wall_only():	
			if c_walljump_stickiness_timer <= 0:
				$Sprite2D.scale.x = 1;
				movement_impetus += Vector2.RIGHT * movement_speed;
		else:
			$Sprite2D.scale.x = 1;
			movement_impetus += Vector2.RIGHT * movement_speed;
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		movement_impetus -= Vector2(velocity.x * 0.2, 0);
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()):
		velocity += Vector2.UP * jump_speed
	if !is_on_floor():
		movement_impetus += get_gravity();
	if Input.is_action_just_pressed("use_item"):
		if held_item != null:
			match held_item.type:
				ItemBox.Items.Hookshot:
					remote_create_hookshot.rpc_id(
						1,
						get_path(),
						get_viewport().get_camera_2d().get_global_mouse_position(),
					);
				ItemBox.Items.Dynamite:
					remote_create_dynamite.rpc_id(
						1,
						get_path(),
						get_viewport().get_camera_2d().get_global_mouse_position(),
					);
			held_item.qty -= 1;
			if held_item.qty <= 0:
				remove_item();
	velocity += movement_impetus;
	velocity.x = clamp(velocity.x, -movement_speed, movement_speed);
	velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 2.0);
	var before_collide_velocity = velocity;
	move_and_slide();
	for n in get_slide_collision_count():
		var collider = get_slide_collision(n).get_collider();
		if collider is Player:
			remote_update_velocity.rpc(
				collider.name,
				before_collide_velocity
			);
			velocity = -before_collide_velocity;

# Methods
@rpc("call_local")
func remote_create_dynamite(shooter_path: NodePath, target: Vector2)->void:
	var hookshot = Dynamite._create_instance(
		get_node(shooter_path),
	);
	get_node("/root/Game/MiscSpawner").add_child(hookshot, true);

@rpc("call_local")
func remote_create_hookshot(shooter_path: NodePath, target: Vector2)->void:
	var hookshot = Hookshot._create_instance(
		get_node(shooter_path),
		target,
	);
	get_node("/root/Game/MiscSpawner").add_child(hookshot, true);

@rpc("any_peer", "call_local")
func remote_update_velocity(collider_name: String, new_velocity: Vector2):
	get_parent().get_node(collider_name).velocity = new_velocity;

var held_item: ItemBox.Item:
	set(new_held_item):
		if new_held_item == null:
			$"/root/Game/UI/HeldItemLabel".text = "No Item";
		else:
			$"/root/Game/UI/HeldItemLabel".text = new_held_item.name;
		held_item = new_held_item;

func pickup_item(item: ItemBox.Item):
	if !is_multiplayer_authority():
		return;
	held_item = item;
	
func remove_item():
	if !is_multiplayer_authority():
		return;
	held_item = null;
