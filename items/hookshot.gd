class_name Hookshot
extends CharacterBody2D

var target_global_direction: Vector2;
var stuck_into_node: Node2D;
var intrinsic_rotation = -PI/2;
var original_shooter_position;
@export var shooter: Node2D;
static var factory_scene_path: String = "res://items/hookshot.tscn";

static func _create_instance(shooter: Node2D, target_global_position: Vector2)->Hookshot:
	var hookshot: Hookshot = load(factory_scene_path).instantiate();
	hookshot.shooter = shooter;
	hookshot.target_global_direction = (target_global_position - shooter.global_position).normalized();
	hookshot.global_position = shooter.global_position + hookshot.target_global_direction * 25;
	hookshot.original_shooter_position = shooter.global_position;
	return hookshot;

func _physics_process(delta: float) -> void:
	$Line2D.points[1] = shooter.global_position - position;
	if stuck_into_node != null:
		$Sprite2D.rotation = position.angle_to(shooter.global_position - global_position) + intrinsic_rotation;
		if shooter is Player:
			shooter.velocity = (global_position - shooter.global_position).normalized() * 300 - get_gravity();
			shooter.move_and_slide();
			if (global_position - shooter.global_position).length() < 50:
				queue_free();
		return;
	$Sprite2D.rotation = position.angle_to(shooter.global_position - global_position) + intrinsic_rotation;
	velocity = target_global_direction * 1300;
	var old_velcoity_ref = velocity;
	move_and_slide();
	for n in get_slide_collision_count():
		var collider = get_slide_collision(n).get_collider();
		if collider is Tile:
			$MaxShootTimer.stop();
			$MaxShootTimer.start();
			stuck_into_node = collider;
		if collider is Player:
			print(123);
			collider.remote_update_velocity(collider.name, old_velcoity_ref);

func _on_max_shoot_timer_timeout() -> void:
	queue_free();
