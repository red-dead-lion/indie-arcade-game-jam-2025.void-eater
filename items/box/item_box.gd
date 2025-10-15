class_name ItemBox;
extends CharacterBody2D;

# Triggers
func _on_item_collect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		match randi() % ItemUtils.ItemType.keys().size():
			ItemUtils.ItemType.Hookshot:
				var item: ItemUtils.Item = ItemUtils.Item.new(
					ItemUtils.ItemType.Hookshot,
					"hookshot",
					"res://items/hookshot/hookshot.png",
					10
				);
				body.pickup_item(item);
			ItemUtils.ItemType.Dynamite:
				var item: ItemUtils.Item = ItemUtils.Item.new(
					ItemUtils.ItemType.Dynamite,
					"dynamite",
					"res://items/dynamite/dynamite.png",
					1
				);
				body.pickup_item(item);
		RPC_remove_item_box();

# Lifecycle
func _physics_process(_delta: float) -> void:
	if !multiplayer.is_server():
		return;
	velocity += get_gravity() / 60;
	move_and_slide();

# Network
@rpc('any_peer')
func RPC_remove_item_box():
	if multiplayer.is_server():
		queue_free();
