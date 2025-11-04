class_name Dynamite;
extends Area2D;

static func create():
	return ItemUtils.Item.new(
		ItemUtils.ItemType.Dynamite,
		"Dynamite",
		"res://items/dynamite/dynamite.png",
		1,
		func(player: Player, _delta: float):
			if Input.is_action_just_pressed("use_item"):
				player.rpc_controller.RPC_create_dynamite.rpc_id(
					Main.SERVER_ID
				);
				player.held_item.qty -= 1;
	);
