class_name ItemBox;
extends CharacterBody2D

enum Items {
	Hookshot,
	Dynamite
}

class Item:
	var type;
	var name;
	var icon_path;
	var qty;
	
	func _init(_type, _name, _icon_path, _qty):
		self.type = _type;
		self.name = _name;
		self.icon_path = _icon_path;
		self.qty = _qty;

@export var _net_is_destroyed = false;

func _enter_tree() -> void:
	set_multiplayer_authority(1);
	get_tree().get_multiplayer().peer_connected.connect(func(_id)->void:
		if _net_is_destroyed:
			queue_free();
	);

func _on_item_collect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		match randi() % 2:
			0:
				var item: Item = Item.new(Items.Hookshot, "hookshot", "res://items/hookshot.png", 10);
				body.pickup_item(item);
			1:
				var item: Item = Item.new(Items.Dynamite, "dynamite", "res://items/dynamite.png", 1);
				body.pickup_item(item);
		_net_is_destroyed = true;
		queue_free();

func _physics_process(_delta: float) -> void:
	if !get_tree().get_multiplayer().is_server():
		return;
	velocity += get_gravity() / 60;
	move_and_slide();
