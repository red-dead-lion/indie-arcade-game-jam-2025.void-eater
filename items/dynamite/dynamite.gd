class_name Dynamite;
extends CharacterBody2D;

# Static
static var factory_scene_path: String = "res://items/dynamite/dynamite.tscn";

static func _create_instance(shooter: Player)->Dynamite:
	var dynamite: Dynamite = load(factory_scene_path).instantiate();
	dynamite.global_position = shooter.global_position;
	return dynamite;

# Settings
@export var smoke_particles: CPUParticles2D;
@export var explosion_particles: CPUParticles2D;
@export var sprite: Sprite2D;
@export var explosion_shape_cast: ShapeCast2D;

# Properties
var is_exploding = false;

# Timers
var apply_force_for_time_after_explosion_timer = 1.0;
var c_apply_force_for_time_after_explosion_timer = 0;

# Triggers
func _on_explode_after_timeout() -> void:
	if !is_multiplayer_authority():
		return;
	smoke_particles.emitting = true;
	explosion_particles.emitting = true;
	sprite.visible = false;
	is_exploding = true;

func _on_smoke_finished() -> void:
	if !multiplayer.is_server():
		return;
	queue_free();

# Lifecycle
func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() or !is_exploding:
		return;
	c_apply_force_for_time_after_explosion_timer += delta;
	for n in explosion_shape_cast.get_collision_count():
		var collision = explosion_shape_cast.get_collider(n);
		if collision is Tile:
			collision.remote_request_queue_free.rpc();
		if collision is Player and (
			c_apply_force_for_time_after_explosion_timer <
			apply_force_for_time_after_explosion_timer
		):
			collision.remote_update_velocity.rpc(
				collision.name,
				-(global_position - collision.global_position).normalized() * 2000
			);
