class_name RevolverShot;
extends CharacterBody2D;

# Static
static var factory_scene_path: String = "res://items/revolver/revolver_bullet.tscn";

static func _create_instance(
	_shooter: Player,
	target_global_position: Vector2
)->RevolverShot:
	var revolver_shot: RevolverShot = load(factory_scene_path).instantiate(true);
	revolver_shot.global_position = _shooter.global_position;
	revolver_shot.target_global_direction = (target_global_position - _shooter.global_position).normalized();
	revolver_shot.shooter = _shooter;
	return revolver_shot;

# Settings
@export var impact_multiplier: int = 3;
@export var shot_speed: int = 1200;
@export var blowback: int = 1000;

# Properties
var target_global_direction: Vector2;
var shooter: Player;
@onready var bullet_forward_cast: RayCast2D = $RayCast2D;

# Lifecycle
func _ready()->void:
	if !is_multiplayer_authority():
		return;
	shooter.rpc_controller.RPC_set_velocity.rpc(
		-target_global_direction * blowback
	);

func _physics_process(_delta: float)->void:
	if !is_multiplayer_authority():
		return;
	rotation = target_global_direction.angle();
	if bullet_forward_cast.get_collider() is Tile:
		target_global_direction = target_global_direction.bounce(
			bullet_forward_cast.get_collision_normal()
		);
	if (
		bullet_forward_cast.get_collider() is Player and
		bullet_forward_cast.get_collider() != shooter
	):
		bullet_forward_cast.get_collider().rpc_controller.RPC_set_velocity.rpc(
			target_global_direction * shot_speed * impact_multiplier,
		);
		queue_free();
	velocity = target_global_direction * shot_speed;
	move_and_slide();
