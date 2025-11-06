class_name GhostMode;
extends Node2D;

const DURATION: float = 5.0;

static func create():
	var ghost_mode_ref = {
		"timer": DURATION
	}
	return ItemUtils.Item.new(
		ItemUtils.ItemType.GhostMode,
		"Ghost Mode",
		"res://items/ghost-mode/ghost_mode.png",
		ceili(DURATION),
		func(player: Player, _delta: float):
			player.collision_mask = 0;
			player.input_enabled = false;
			player.player_sprite.modulate = Color(1,1,1,0);
			player.held_item_sprite.modulate = Color(1,1,1,0.5);
			player.velocity = Vector2.ZERO;
			if Input.is_action_pressed("ui_up"):
				player.velocity.y = -player.movement_speed;
			if Input.is_action_pressed("ui_down"):
				player.velocity.y = player.movement_speed;
			if Input.is_action_pressed("ui_left"):
				player.velocity.x = -player.movement_speed;
			if Input.is_action_pressed("ui_right"):
				player.velocity.x = player.movement_speed;
			ghost_mode_ref.timer -= _delta;
			if(ghost_mode_ref.timer <= 0):
				player.collision_mask = (1 << 0) | (1 << 1);
				player.input_enabled = true;
				player.player_sprite.modulate = Color(1,1,1,1);
				player.held_item_sprite.modulate = Color(1,1,1,1);
			player.held_item.qty = ceili(ghost_mode_ref.timer);
	);
