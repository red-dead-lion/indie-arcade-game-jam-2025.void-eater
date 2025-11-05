class_name Hookshot;
extends Area2D;

static func create():
	return ItemUtils.Item.new(
		ItemUtils.ItemType.Hookshot,
		"Hookshot",
		"res://items/hookshot/hookshot.png",
		12,
		func(player: Player, _delta: float):
			if Input.is_action_just_pressed("use_item"):
				print('making hookshot');
				player.rpc_controller.RPC_create_hookshot.rpc_id(
					Main.SERVER_ID,
					player.get_viewport().get_camera_2d().get_global_mouse_position(),
				);
				player.held_item.qty -= 1;
	);
