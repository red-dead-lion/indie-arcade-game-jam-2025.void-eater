class_name Uzi;
extends Area2D;

static func create():
	var cooldown_timer = {
		"current": 0,
		"timeout": 0.07
	};
	return ItemUtils.Item.new(
		ItemUtils.ItemType.Uzi,
		"Uzi",
		"res://items/uzi/uzi.png",
		32,
		func(player: Player, delta: float):
			if Input.is_action_pressed("use_item"):
				cooldown_timer.current += delta;
				if cooldown_timer.current > cooldown_timer.timeout:
					player.rpc_controller.RPC_create_uzi_shot.rpc_id(
						Main.SERVER_ID,
						player.get_viewport()
							.get_camera_2d()
							.get_global_mouse_position(),
					)
					cooldown_timer.current = 0;
					player.held_item.qty -= 1;
	);
