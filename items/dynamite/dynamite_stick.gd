class_name DynamiteStick;
extends CharacterBody2D;

# Static
static var factory_scene_path: String = "res://items/dynamite/dynamite_stick.tscn";

static func _create_instance(shooter: Player)->DynamiteStick:
	var dynamite: DynamiteStick = load(factory_scene_path).instantiate();
	dynamite.global_position = shooter.global_position;
	return dynamite;

# Settings
@export var smoke_particles: CPUParticles2D;
@export var explosion_particles: CPUParticles2D;
@export var sprite: Sprite2D;
@export var explosion_shape_cast: ShapeCast2D;
@export var countdown_animation: Countdown;

# Properties
var is_exploding = false;
var explosion_imminant_when_x_seconds_remaining = 1.0;
var explode_timer = 3;

# Timers
var apply_force_for_time_after_explosion_timer = 1.0;
var c_apply_force_for_time_after_explosion_timer = 0;

# Triggers
func _on_smoke_finished() -> void:
	if !multiplayer.is_server():
		return;
	queue_free();

func _on_countdown_timer_tick_animation_complete() -> void:
	explode_timer -= 1;
	if explode_timer == 0:
		explode();
	elif explode_timer == 1.0:
		countdown_animation.play_countdown_label_red(var_to_str(explode_timer));
	else:
		countdown_animation.play_countdown_label(var_to_str(explode_timer));
	

# Lifecycle
func _ready() -> void:
	countdown_animation.play_countdown_label(var_to_str(explode_timer));

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() or !is_exploding:
		return;
	c_apply_force_for_time_after_explosion_timer += delta;
	for n in explosion_shape_cast.get_collision_count():
		var collision = explosion_shape_cast.get_collider(n);
		if collision is Tile:
			collision.RPC_queue_free.rpc();
		elif collision is BGTile:
			collision.RPC_remove_tile.rpc();
		elif collision is Player and (
			c_apply_force_for_time_after_explosion_timer <
			apply_force_for_time_after_explosion_timer
		):
			collision.rpc_controller.RPC_set_velocity.rpc(
				-(global_position - collision.global_position).normalized() * 2000
			);

# Methods
func explode() -> void:
	if !is_multiplayer_authority():
		return;
	smoke_particles.emitting = true;
	explosion_particles.emitting = true;
	sprite.visible = false;
	is_exploding = true;
