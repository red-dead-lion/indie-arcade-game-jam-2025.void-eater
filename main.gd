class_name Main;
extends Node2D

@export var level_root: Node;
@export var room_scene: PackedScene;
@export var size: Vector2;
@export var start_position: Vector2;

static var instance: Main;

enum CardinalDirection {
	Up = 0,
	Down = 1,
	Left = 2,
	Right = 3,
};

const ALL_CARDINAL_DIRECTIONS = [
	CardinalDirection.Up,
	CardinalDirection.Right,
	CardinalDirection.Down,
	CardinalDirection.Left,
];

static func cardinal_direction_to_vector(cardinal_direction: CardinalDirection):
	match cardinal_direction:
		CardinalDirection.Up:
			return Vector2(-1, 0)
		CardinalDirection.Down:
			return Vector2(1, 0)
		CardinalDirection.Left:
			return Vector2(0, -1)
		CardinalDirection.Right:
			return Vector2(0, 1)

static func vectors_to_cardinal_direction_pair(
	vectorA: Vector2,
	vectorB: Vector2
)->Array[CardinalDirection]:
	if vectorA - vectorB == Vector2.UP:
		return [CardinalDirection.Up,CardinalDirection.Down];
	if vectorA - vectorB == Vector2.DOWN:
		return [CardinalDirection.Down, CardinalDirection.Up];
	if vectorA - vectorB == Vector2.LEFT:
		return [CardinalDirection.Left, CardinalDirection.Right];
	if vectorA - vectorB == Vector2.RIGHT:
		return [CardinalDirection.Right, CardinalDirection.Left];
	return [];

static func c_to_s(c: CardinalDirection):
	match c:
		Main.CardinalDirection.Up:
			return "up";
		Main.CardinalDirection.Down:
			return "down";
		Main.CardinalDirection.Left:
			return "left";
		Main.CardinalDirection.Right:
			return "right";

class GridNode:
	var parent: GridNode;
	var index_2d: Vector2;
	var exits: Array[CardinalDirection];
	func _init(index_2d: Vector2, parent: GridNode = null):
		self.index_2d = index_2d;
		self.parent = parent;
		
	func make_array_of_grid_node_neighbors()->Array[GridNode]:
		return [
			GridNode.new(index_2d + Vector2(-1, 0), self),
			GridNode.new(index_2d + Vector2(1, 0), self),
			GridNode.new(index_2d + Vector2(0, -1), self),
			GridNode.new(index_2d + Vector2(0, 1), self),
		];

var has_generated_level = false;

func _ready()->void:
	instance = self;

func create_level_from_properties()->void:
	generate_level(level_root, room_scene, size, start_position);

static func generate_level(parent: Node, room_scene: PackedScene, size: Vector2, start_pos: Vector2)->void:
	print('generate');
	var grid_graph = generate_grid_via_digger_algorithm(
		size,
		[GridNode.new(start_pos)],
	);
	for node in grid_graph:
		var room: Room = room_scene.instantiate();
		room.position.x = 9 * 32 * node.index_2d.x + 128;
		room.position.y = 9 * 32 * node.index_2d.y;
		parent.add_child(room, true);
		for exit in node.exits:
			room.remove_wall(exit);
		
static func generate_grid_via_digger_algorithm(
	size: Vector2 = Vector2(3,3),
	nodes: Array[GridNode] = [GridNode.new(Vector2(0,0))],
	current_node: GridNode = null
)->Array[GridNode]:
	if current_node == null:
		current_node = nodes[0];
	# setup all cardinal directions to check
	var grid_node_neighbors: Array[GridNode] = current_node.make_array_of_grid_node_neighbors();
	# remove closed node neigbors to determine remaining open nodes
	grid_node_neighbors = grid_node_neighbors.filter(func (open_node):
		return !(
			(open_node.index_2d.x < 0 or open_node.index_2d.x > size.x - 1) or
			(open_node.index_2d.y < 0 or open_node.index_2d.y > size.y - 1)
		)
	).filter(func (open_node):
		for node in nodes:
			if node.index_2d == open_node.index_2d:
				return false;
		return true;
	);
	# add random variation
	grid_node_neighbors.shuffle();
	# iterate open nodes, add to nodes graph, call function recursively
	for grid_node_neighbor in grid_node_neighbors:
		# check that node is still open
		var is_node_open = true;
		for node in nodes:
			if node.index_2d == grid_node_neighbor.index_2d:
				is_node_open = false;
		if !is_node_open:
			continue;
		# Covnert vector back to cardinal
		var cardinal_direction_between_nodes = vectors_to_cardinal_direction_pair(
			grid_node_neighbor.index_2d,
			current_node.index_2d
		)[0];
		var inverse_cardinal_direction_between_nodes = vectors_to_cardinal_direction_pair(
			grid_node_neighbor.index_2d,
			current_node.index_2d
		)[1];
		current_node.exits.append(cardinal_direction_between_nodes);
		grid_node_neighbor.exits.append(inverse_cardinal_direction_between_nodes);
		grid_node_neighbor.parent = current_node;
		nodes.append(grid_node_neighbor);
		generate_grid_via_digger_algorithm(size, nodes, grid_node_neighbor);
	return nodes;
