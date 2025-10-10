class_name ItemBox;
extends CharacterBody2D

enum Items {
	Hookshot
}

class Item:
	var type;
	var name;
	var icon_path;
	var qty;
	
	func _init(type, name, icon_path, qty):
		self.type = type;
		self.name = name;
		self.icon_path = icon_path;
		self.qty = qty;

@export var _net_is_destroyed = false;

func _enter_tree() -> void:
	set_multiplayer_authority(1);
	get_tree().get_multiplayer().peer_connected.connect(func(id)->void:
		if _net_is_destroyed:
			queue_free();
	);

func _on_item_collect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var item: Item = Item.new(Items.Hookshot, "hookshot", "", 10);
		body.pickup_item(item);
		_net_is_destroyed = true;
		queue_free();

func _physics_process(delta: float) -> void:
	if !get_tree().get_multiplayer().is_server():
		return;
	velocity += get_gravity() / 60;
	move_and_slide();
