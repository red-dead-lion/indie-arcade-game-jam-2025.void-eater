class_name UziShot;
extends Area2D;

# Static
static var factory_scene_path: String = "res://items/uzi/uzi_bullet.tscn";

static func _create_instance(_shooter: Player, target_global_position: Vector2)->UziShot:
	var uzi_shot: UziShot = load(factory_scene_path).instantiate();
	uzi_shot.global_position = _shooter.global_position;
	uzi_shot.target_global_direction = (target_global_position - _shooter.global_position).normalized();
	uzi_shot.shooter = _shooter;
	return uzi_shot;

# Settings
@export var impact_multiplier: int = 40;
@export var shot_speed: int = 25;
@export var blowback: int = 125;

# Properties
var target_global_direction: Vector2;
var shooter: Player;

# Triggers
func _on_body_entered(body: Node2D) -> void:
	if !is_multiplayer_authority():
		return;
	if body != shooter:
		if body is Player:
			body.remote_update_velocity.rpc(
				body.name,
				target_global_direction * shot_speed * impact_multiplier
			);
		queue_free();
		

# Lifecycle
func _ready()->void:
	if !is_multiplayer_authority():
		return;
	rotation = target_global_direction.angle();
	shooter.remote_update_velocity.rpc(
		shooter.name,
		-target_global_direction * blowback
	);

func _physics_process(_delta: float)->void:
	if !is_multiplayer_authority():
		return;
	global_position += target_global_direction * shot_speed;
	
