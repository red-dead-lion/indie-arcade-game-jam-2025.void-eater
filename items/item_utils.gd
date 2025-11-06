class_name ItemUtils;
extends Node;

enum ItemType {
	Hookshot = 0,
	Dynamite = 1,
	Uzi = 2,
	Revolver = 3,
	GhostMode = 4,
};

class Item:
	var type: ItemType;
	var name: String;
	var icon_path: String;
	var qty: int;
	var use;
	
	func _init(_type: ItemType, _name: String, _icon_path: String, _qty: int, _on_use: Callable):
		self.type = _type;
		self.name = _name;
		self.icon_path = _icon_path;
		self.qty = _qty;
		self.use = _on_use;
	
	
