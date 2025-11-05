class_name HookshotRope
extends CharacterBody2D;

# Static
static var factory_scene_path: String = "res://items/hookshot/hookshot_rope.tscn";

static func _create_instance(_shooter: Player, target_global_position: Vector2)->HookshotRope:
	var hookshot: HookshotRope = load(factory_scene_path).instantiate();
	hookshot.shooter = _shooter;
	hookshot.target_global_direction = (target_global_position - _shooter.global_position).normalized();
	hookshot.global_position = _shooter.global_position + hookshot.target_global_direction * 15;
	hookshot.original_shooter_position = _shooter.global_position;
	return hookshot;

# Settings
@export var shooter: Node2D;
@export var rope_line_2d: Line2D;
@export var sprite: Sprite2D;
@export var shoot_timer: Timer;

# Properties
var target_global_direction: Vector2;
var stuck_into_node: Node2D;
var intrinsic_rotation = -PI/2;
var original_shooter_position;

# Triggers
func _on_max_shoot_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free();

# Lifecycle
func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return;
	rope_line_2d.points[1] = shooter.global_position - position;
	sprite.rotation = position.angle_to(shooter.global_position - global_position) + intrinsic_rotation;
	if stuck_into_node != null:
		if shooter is Player:
			shooter.rpc_controller.RPC_set_velocity.rpc(
				(
					global_position - shooter.global_position
				).normalized() * 900 - get_gravity()
			);
			if (global_position - shooter.global_position).length() < 50:
				queue_free();
		return;
	velocity = target_global_direction * 1600;
	var old_velcoity_ref = velocity;
	move_and_slide();
	for n in get_slide_collision_count():
		var collider = get_slide_collision(n).get_collider();
		if collider is Tile:
			shoot_timer.stop();
			shoot_timer.start();
			stuck_into_node = collider;
		if collider is Player:
			collider.rpc_controller.RPC_set_velocity.rpc(
				old_velcoity_ref,
			);
