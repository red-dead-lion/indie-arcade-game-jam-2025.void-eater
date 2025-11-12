class_name Main;
extends Node2D;

# Settings
@export var level_root: Node;
@export var void_root: Node;
@export var boxes_root: Node;
@export var misc_root: Node;
@export var room_scene: PackedScene;
@export var void_scene: PackedScene;
@export var size: Vector2;
@export var start_position: Vector2;
@export var players_spawner: MultiplayerSpawner;
@export var rooms_spawner: MultiplayerSpawner;
@export var boxes_spawner: MultiplayerSpawner;
@export var misc_spawner: MultiplayerSpawner;

# Static
const SERVER_ID = 1;
static var instance: Main;

static func generate_level(
	rooms_parent: Node,
	_room_scene: PackedScene,
	void_parent: Node,
	_void_scene: PackedScene,
	_size: Vector2,
	start_pos: Vector2
)->void:
	var grid_graph = DiggerLevelGenerationUtilities.generate_cells(
		_size,
		[DiggerLevelGenerationUtilities.Cell.new(start_pos)],
	);
	var the_void = _void_scene.instantiate();
	void_parent.add_child(the_void, true);
	for node in grid_graph:
		var room: Room = _room_scene.instantiate();
		room.position.x = 9 * 32 * node.index_2d.x + 130;
		room.position.y = 9 * 32 * node.index_2d.y;
		room.alarm_started.connect(the_void._on_room_alarm_started);
		room.sucked_up.connect(the_void._on_room_sucked_up);
		rooms_parent.add_child(room, true);
		for exit in node.exits:
			room.remove_wall(exit);

# Lifecycle
func _ready()->void:
	instance = self;

# Methods
func create_level_from_properties()->void:
	generate_level(level_root, room_scene, void_root, void_scene, size, start_position);
	$SpawnBoxTimer.start();

# Network
@rpc("call_local", "reliable")
func RPC_clear_level()->void:
	for s in level_root.get_children():
		s.queue_free();
	for s in void_root.get_children():
		s.queue_free();
	for s in boxes_root.get_children():
		s.queue_free();
	for s in misc_root.get_children():
		s.queue_free();
	$SpawnBoxTimer.stop();
