class_name Player;
extends CharacterBody2D;

# Static
static var factory_scene_path = "res://player/player.tscn";

static func _create_instance(id: int, players_root_ndoe: Node, rooms_root_node: Node)->void:
	var player = load(factory_scene_path).instantiate();
	player.name = str(id);
	players_root_ndoe.add_child(player, true);
	player.remote_update_position.rpc(
		rooms_root_node.get_child(
			randi() % rooms_root_node.get_child_count()
		).global_position
	);

# Settings
@export var movement_speed = 500;
@export var jump_speed = 2000;
@export var wall_jump_impetus = 1000;
@export var held_item_sprite_path: String;

# Properties
var in_progress_hookshot: Hookshot;
var walljump_lr_fromdir: Vector2;
var held_item: ItemUtils.Item:
	set(new_held_item):
		GameUIController.instance.held_item = new_held_item
		held_item = new_held_item;
		if new_held_item != null:
			held_item_sprite_path = new_held_item.icon_path;
		else:
			held_item_sprite_path = "";
		
# Timers
var walljump_stickiness_timer = 0.266;
var c_walljump_stickiness_timer = 0;
var uzi_shot_cooldown_timer = 0.1;
var c_uzi_shot_cooldown_timer = 0;

# Triggers
func _on_multiplayer_synchrnoizer_synchrnoized()->void:
	RPC_update_held_item_sprite.rpc();

# Lifecycle
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
	$HeldItemSprite2D.rotation = (
		get_viewport().get_camera_2d().get_global_mouse_position() - position
	).angle();
	if Input.is_action_pressed("use_item"):
		if held_item != null:
			match held_item.type:
				ItemUtils.ItemType.Uzi:
					c_uzi_shot_cooldown_timer += delta;
					if c_uzi_shot_cooldown_timer > uzi_shot_cooldown_timer:
						remote_create_uzi_shot.rpc_id(
							1,
							get_path(),
							get_viewport().get_camera_2d().get_global_mouse_position(),
						);
						c_uzi_shot_cooldown_timer = 0;
						held_item.qty -= 1;
	if Input.is_action_just_pressed("use_item"):
		if held_item != null:
			match held_item.type:
				ItemUtils.ItemType.Hookshot:
					remote_create_hookshot.rpc_id(
						1,
						get_path(),
						get_viewport().get_camera_2d().get_global_mouse_position(),
					);
					held_item.qty -= 1;
				ItemUtils.ItemType.Dynamite:
					remote_create_dynamite.rpc_id(
						1,
						get_path(),
					);
					held_item.qty -= 1;
	if held_item != null:
		GameUIController.instance.held_item_qty_label.text = str(held_item.qty);
		if held_item.qty <= 0:
			remove_item();
	velocity += movement_impetus;
	if velocity.x > movement_speed or velocity.x < -movement_speed:
		velocity.x *= 0.96;
	if velocity.y > movement_speed or velocity.y < -movement_speed:
		velocity.y *= 0.96;
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
func pickup_item(item: ItemUtils.Item):
	if !is_multiplayer_authority():
		return;
	held_item = item;
	
func remove_item():
	if !is_multiplayer_authority():
		return;
	held_item = null;
	
# Network
@rpc("any_peer", "call_local")
func remote_update_position(_global_position: Vector2)->void:
	self.global_position = _global_position;

@rpc("any_peer", "call_local")
func remote_update_velocity(collider_name: String, new_velocity: Vector2):
	get_parent().get_node(collider_name).velocity = new_velocity;

@rpc("call_local")
func remote_create_uzi_shot(shooter_path: NodePath, target: Vector2)->void:
	var shot = UziShot._create_instance(
		get_node(shooter_path),
		target,
	);
	get_node("/root/Game/MiscSpawner").add_child(shot, true);

@rpc("call_local")
func remote_create_hookshot(shooter_path: NodePath, target: Vector2)->void:
	if in_progress_hookshot != null:
		in_progress_hookshot.queue_free();
	in_progress_hookshot = Hookshot._create_instance(
		get_node(shooter_path),
		target,
	);
	get_node("/root/Game/MiscSpawner").add_child(in_progress_hookshot, true);
	
@rpc("call_local")
func remote_create_dynamite(shooter_path: NodePath)->void:
	var hookshot = Dynamite._create_instance(
		get_node(shooter_path),
	);
	get_node("/root/Game/MiscSpawner").add_child(hookshot, true);

@rpc("any_peer", "call_local")
func RPC_update_held_item_sprite()->void:
	if !held_item_sprite_path.is_empty():
		$HeldItemSprite2D.texture = load(held_item_sprite_path);
	else:
		$HeldItemSprite2D.texture = null
