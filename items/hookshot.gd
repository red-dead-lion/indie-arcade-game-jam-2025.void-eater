class_name Hookshot
extends CharacterBody2D

var target_global_direction: Vector2;
var stuck_into_node: Node2D;
var intrinsic_rotation = -PI/2;
var original_shooter_position;
@export var shooter: Node2D;
static var factory_scene_path: String = "res://items/hookshot.tscn";

func _enter_tree() -> void:
	set_multiplayer_authority(1);

static func _create_instance(shooter: Player, target_global_position: Vector2)->Hookshot:
	var hookshot: Hookshot = load(factory_scene_path).instantiate();
	hookshot.shooter = shooter;
	hookshot.target_global_direction = (target_global_position - shooter.global_position).normalized();
	hookshot.global_position = shooter.global_position + hookshot.target_global_direction * 15;
	hookshot.original_shooter_position = shooter.global_position;
	return hookshot;

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return;
	$Line2D.points[1] = shooter.global_position - position;
	$Sprite2D.rotation = position.angle_to(shooter.global_position - global_position) + intrinsic_rotation;
	if stuck_into_node != null:
		if shooter is Player:
			shooter.remote_update_velocity.rpc(shooter.name, (global_position - shooter.global_position).normalized() * 900 - get_gravity())
			if (global_position - shooter.global_position).length() < 50:
				queue_free();
		return;
	velocity = target_global_direction * 1600;
	var old_velcoity_ref = velocity;
	move_and_slide();
	for n in get_slide_collision_count():
		var collider = get_slide_collision(n).get_collider();
		if collider is Tile:
			$MaxShootTimer.stop();
			$MaxShootTimer.start();
			stuck_into_node = collider;
		if collider is Player:
			collider.remote_update_velocity.rpc(collider.name, old_velcoity_ref);

func _on_max_shoot_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free();
