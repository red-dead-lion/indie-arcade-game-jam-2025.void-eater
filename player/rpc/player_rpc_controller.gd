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
)->HookshotRope:
	var hookshot_rope = HookshotRope._create_instance(
		player,
		target,
	);
	Main.instance.misc_spawner.add_child(player.in_progress_hookshot, true);
	return hookshot_rope;
	
@rpc("call_local")
func RPC_create_dynamite()->void:
	var hookshot = DynamiteStick._create_instance(
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
	item_texture2d_path: String
)->void:
	player.held_item_sprite.texture = load(item_texture2d_path);
