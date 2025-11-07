class_name GameUIController;
extends Control;

# Static
static var instance: GameUIController;

# Settings
@export var held_item_name_label: Label;
@export var held_item_qty_label: Label;
@export var held_item_icon: TextureRect;

# Properties
var held_item: ItemUtils.Item:
	set(new_held_item):
		if new_held_item == null:
			held_item_name_label.text = "No Item";
			held_item_icon.texture = null;
			held_item_qty_label.text = ""
		else:
			held_item_name_label.text = new_held_item.name;
			held_item_icon.texture = load(new_held_item.icon_path);
			held_item_qty_label.text = var_to_str(new_held_item.qty);
		held_item = new_held_item;
	
# Lifecycle
func _ready()->void:
	instance = self;
	
# Network
@rpc('any_peer', 'call_local')
func RPC_show_game_ui()->void:
	visible = true;

@rpc('any_peer', 'call_local')
func RPC_hide_game_ui()->void:
	visible = false;
