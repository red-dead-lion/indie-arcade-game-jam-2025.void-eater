class_name Dynamite;
extends CharacterBody2D

static var factory_scene_path: String = "res://items/dynamite.tscn";
var is_exploding = false;

static func _create_instance(shooter: Player)->Dynamite:
	var dynamite: Dynamite = load(factory_scene_path).instantiate();
	dynamite.global_position = shooter.global_position;
	return dynamite;

func _enter_tree() -> void:
	set_multiplayer_authority(1);

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() or !is_exploding:
		return;
	for n in $ExplosionCastShape.get_collision_count():
		var collision = $ExplosionCastShape.get_collider(n);
		if collision is Tile:
			collision.remote_request_queue_free.rpc();
		if collision is Player:
			collision.remote_update_velocity.rpc(
				collision.name,
				collision.velocity - (global_position - collision.global_position).normalized() * 5000
			);

func _on_explode_after_timeout() -> void:
	if !is_multiplayer_authority():
		return;
	$Smoke.emitting = true;
	$Explosion.emitting = true;
	is_exploding = true;

func _on_smoke_finished() -> void:
	if !is_multiplayer_authority():
		return;
	queue_free();
