class_name ItemBox;
extends CharacterBody2D;

# Triggers
func _on_item_collect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var item: ItemUtils.Item = null;
		match ItemUtils.ItemType.Revolver:#randi() % ItemUtils.ItemType.keys().size():
			ItemUtils.ItemType.Revolver:
				item = ItemUtils.Item.new(
					ItemUtils.ItemType.Revolver,
					"Revolver",
					"res://items/revolver/revolver.png",
					12
				);
			ItemUtils.ItemType.Hookshot:
				item = ItemUtils.Item.new(
					ItemUtils.ItemType.Hookshot,
					"Hookshot",
					"res://items/hookshot/hookshot.png",
					5
				);
			ItemUtils.ItemType.Dynamite:
				item = ItemUtils.Item.new(
					ItemUtils.ItemType.Dynamite,
					"Dynamite",
					"res://items/dynamite/dynamite.png",
					1
				);
			ItemUtils.ItemType.Uzi:
				item = ItemUtils.Item.new(
					ItemUtils.ItemType.Uzi,
					"Uzi",
					"res://items/uzi/uzi.png",
					99
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
