class_name ItemBox;
extends CharacterBody2D;

# Triggers
func _on_item_collect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var item: ItemUtils.Item = null;
		match randi() % ItemUtils.ItemType.keys().size():
			ItemUtils.ItemType.Revolver:
				item = Revolver.create();
			ItemUtils.ItemType.Hookshot:
				item = Hookshot.create();
			ItemUtils.ItemType.Dynamite:
				item = Dynamite.create();
			ItemUtils.ItemType.Uzi:
				item = Uzi.create();
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
