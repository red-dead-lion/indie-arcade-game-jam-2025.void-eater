class_name ItemUtils;
extends Node;

enum ItemType {
	Hookshot,
	Dynamite,
	Uzi,
	Revolver,
};

class Item:
	var type: ItemType;
	var name: String;
	var icon_path: String;
	var qty: int;
	
	func _init(_type: ItemType, _name: String, _icon_path: String, _qty: int):
		self.type = _type;
		self.name = _name;
		self.icon_path = _icon_path;
		self.qty = _qty;
