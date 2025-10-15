class_name Main;
extends Node2D

@export var level_root: Node;
@export var room_scene: PackedScene;
@export var size: Vector2;
@export var start_position: Vector2;

static var instance: Main;

func _enter_tree() -> void:
	set_multiplayer_authority(1);

func _ready()->void:
	instance = self;

func create_level_from_properties()->void:
	generate_level(level_root, room_scene, size, start_position);

static func generate_level(
	parent: Node,
	_room_scene: PackedScene,
	_size: Vector2,
	start_pos: Vector2
)->void:
	var grid_graph = DiggerLevelGenerationUtilities.generate_cells(
		_size,
		[DiggerLevelGenerationUtilities.Cell.new(start_pos)],
	);
	for node in grid_graph:
		var room: Room = _room_scene.instantiate();
		room.position.x = 9 * 32 * node.index_2d.x + 128;
		room.position.y = 9 * 32 * node.index_2d.y;
		parent.add_child(room, true);
		for exit in node.exits:
			room.remove_wall(exit);
		
