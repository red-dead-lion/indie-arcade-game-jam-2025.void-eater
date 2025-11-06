class_name Player;
extends CharacterBody2D;

enum HorizontalSpriteDirection {
	LEFT = -1,
	RIGHT = 1,
}

const VELOCITY_DAMPENING_RATIO = 0.96;

# Static
static var factory_scene_path = "res://player/player.tscn";

static func _create_instance(id: int, players_root_ndoe: Node, rooms_root_node: Node)->void:
	var player = load(factory_scene_path).instantiate();
	player.name = str(id);
	players_root_ndoe.add_child(player, true);
	player.rpc_controller.RPC_set_position.rpc(
		rooms_root_node.get_child(
			randi() % rooms_root_node.get_child_count()
		).global_position
	);

# Settings
@export var movement_speed = 500;
@export var jump_speed = 2000;
@export var wall_jump_impetus = 1000;
@export var rpc_controller: PlayerRPCController;

# Properties
@onready var held_item_sprite: Sprite2D = $HeldItemSprite2D;
@onready var player_sprite: Sprite2D = $Sprite2D;
@onready var wall_detection_raycast: RayCast2D = $RayCast2D;
var movement_impetus: Vector2;
var walljump_lr_fromdir: Vector2;
var held_item: ItemUtils.Item:
	set(new_held_item):
		GameUIController.instance.held_item = new_held_item
		held_item = new_held_item;
var input_enabled = true;

# Timers
var walljump_stickiness_timer = 0.266;
var c_walljump_stickiness_timer = 0;
var uzi_shot_cooldown_timer = 0.07;
var c_uzi_shot_cooldown_timer = 0;

# Lifecycle
func _enter_tree()->void:
	set_multiplayer_authority(name.to_int(), true);

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return;
		
	handle_movement_input(delta);
	if held_item != null:
		held_item.use.call(self, delta);
		update_held_item_sprite();
		GameUIController.instance.held_item_qty_label.text = str(held_item.qty);
		if held_item.qty <= 0:
			remove_item();
	if input_enabled:
		velocity += movement_impetus;
		dampen_player_velocity();
		var params = PhysicsShapeQueryParameters2D.new();
		params.shape = $CollisionShape2D.shape;
		params.transform = global_transform;
		params.margin = 0.001;
		for shape in get_world_2d().direct_space_state.intersect_shape(params, 8):
			if shape.collider.collision_layer & (1 << 1) != 0:
				position -= Vector2.ONE * 8;

	var before_collide_velocity = velocity;
	move_and_slide();
	handle_interaction_with_other_player_bodies(before_collide_velocity);

# Methods
func handle_interaction_with_other_player_bodies(n_minus_one_velocity: Vector2):
	for n in get_slide_collision_count():
		var collider = get_slide_collision(n).get_collider();
		if collider is Player:
			collider.rpc_controller.RPC_set_velocity.rpc(
				n_minus_one_velocity
			);
			velocity = -n_minus_one_velocity;

func dampen_player_velocity():
	if velocity.x > movement_speed or velocity.x < -movement_speed:
		velocity.x *= VELOCITY_DAMPENING_RATIO;
	if velocity.y > movement_speed or velocity.y < -movement_speed:
		velocity.y *= VELOCITY_DAMPENING_RATIO;

func update_held_item_sprite():
	if get_viewport().get_camera_2d().get_global_mouse_position().x < position.x:
		held_item_sprite.scale.y = -2;
	else:
		held_item_sprite.scale.y = 2;
	held_item_sprite.rotation = (
		get_viewport().get_camera_2d().get_global_mouse_position() - position
	).angle();

func handle_drop_from_wall_input():
	if Input.is_action_pressed("ui_down") and is_on_wall(): 
		c_walljump_stickiness_timer = 0;
		if player_sprite.scale.x == -1:
			position = position + Vector2.RIGHT * 5;
		elif player_sprite.scale.x == 1:
			position = position + Vector2.LEFT * 5;

func handle_wall_jump_input(
	for_action_input_label: String,
	for_sprite_direction: HorizontalSpriteDirection,
	on_wall_rotation: float
):
	if is_on_wall_only() and !wall_detection_raycast.is_colliding() and player_sprite.scale.x == for_sprite_direction:
		if Input.is_action_pressed(for_action_input_label):
			c_walljump_stickiness_timer = walljump_stickiness_timer;
		rotation = on_wall_rotation;
		velocity.y = clamp(velocity.y, -jump_speed, jump_speed / 8.0);
		if Input.is_action_just_pressed("ui_accept"):
			movement_impetus.x += wall_jump_impetus * -for_sprite_direction;
			walljump_lr_fromdir = Vector2(for_sprite_direction, 0);

func handle_stop_movement_input():
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		movement_impetus -= Vector2(velocity.x * 0.2, 0);
		
func handle_floor_jump_input():
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()):
		velocity += Vector2.UP * jump_speed
	if !is_on_floor():
		movement_impetus += get_gravity();

func handle_horizontal_movement(
	delta: float,
	for_input_label: String,
	horizontal_direction: HorizontalSpriteDirection,
):
	if Input.is_action_pressed(for_input_label):
		c_walljump_stickiness_timer -= delta;
		if is_on_wall_only():
			if c_walljump_stickiness_timer <= 0:
				player_sprite.scale.x = horizontal_direction;
				movement_impetus += Vector2(horizontal_direction, 0) * movement_speed;
		else:
			player_sprite.scale.x = horizontal_direction;
			movement_impetus += Vector2(horizontal_direction, 0) * movement_speed;

func handle_movement_input(delta: float):
	movement_impetus = Vector2.ZERO;
	rotation = 0;
	handle_drop_from_wall_input();
	handle_wall_jump_input("ui_left", HorizontalSpriteDirection.LEFT, -PI / 4);
	handle_wall_jump_input("ui_right", HorizontalSpriteDirection.RIGHT, PI / 4);
	handle_floor_jump_input();
	handle_stop_movement_input();
	if velocity.x > -movement_speed:
		handle_horizontal_movement(
			delta,
			"ui_left",
			HorizontalSpriteDirection.LEFT
		);
	if velocity.x < movement_speed:
		handle_horizontal_movement(
			delta,
			"ui_right",
			HorizontalSpriteDirection.RIGHT
		);

func pickup_item(item: ItemUtils.Item):
	if !is_multiplayer_authority():
		return;
	held_item = item;
	rpc_controller.RPC_update_held_item_sprite.rpc(
		held_item.icon_path
	);

func remove_item():
	if !is_multiplayer_authority():
		return;
	held_item = null;
	rpc_controller.RPC_update_held_item_sprite.rpc('');
