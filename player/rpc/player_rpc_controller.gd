class_name PlayerRPCController;
extends Node;

@export var player: Player;

# Network
@rpc("any_peer", "call_local")
func RPC_set_position(
	_global_position: Vector2
)->void:
	player.global_position = _global_position;

@rpc("any_peer", "call_local")
func RPC_set_velocity(
	new_velocity: Vector2
):
	player.velocity = new_velocity;

@rpc("call_local")
func RPC_create_uzi_shot(
	target: Vector2,
)->void:
	var shot = UziShot._create_instance(
		player,
		target,
	);
	Main.instance.misc_spawner.add_child(shot, true);

@rpc("call_local")
func RPC_create_hookshot(
	target: Vector2,
)->void:
	if player.in_progress_hookshot != null:
		player.in_progress_hookshot.queue_free();
	player.in_progress_hookshot = Hookshot._create_instance(
		player,
		target,
	);
	Main.instance.misc_spawner.add_child(player.in_progress_hookshot, true);
	
@rpc("call_local")
func RPC_create_dynamite()->void:
	var hookshot = Dynamite._create_instance(
		player,
	);
	Main.instance.misc_spawner.add_child(hookshot, true);

@rpc("call_local")
func RPC_create_revolver_shot(
	target: Vector2,
)->void:
	var revolver_shot = RevolverShot._create_instance(
		player,
		target,
	);
	Main.instance.misc_spawner.add_child(revolver_shot, true);

@rpc("call_local")
func RPC_update_held_item_sprite(
	player_item_sprite2d_node: Sprite2D,
	item_texture2d: Texture2D
)->void:
	player_item_sprite2d_node.texture = item_texture2d;
