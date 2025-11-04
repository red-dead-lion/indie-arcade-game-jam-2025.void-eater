class_name Revolver;
extends Area2D;

static func create():
	return ItemUtils.Item.new(
		ItemUtils.ItemType.Revolver,
		"Revovler",
		"res://items/revolver/revolver.png",
		6,
		func(player: Player, _delta: float):
			if Input.is_action_just_pressed("use_item"):
				player.rpc_controller.RPC_create_revolver_shot.rpc_id(
					Main.SERVER_ID,
					player.get_viewport().get_camera_2d().get_global_mouse_position(),
				);
				player.held_item.qty -= 1;
	);
