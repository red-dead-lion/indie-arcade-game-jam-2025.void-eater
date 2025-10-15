class_name DiggerLevelGenerationUtilities;

class Cell:
	var parent: Cell;
	var index_2d: Vector2;
	var exits: Array[CardinalUtilities.Direction];
	func _init(_index_2d: Vector2, _parent: Cell = null):
		self.index_2d = _index_2d;
		self.parent = _parent;
		
	func make_array_of_grid_cell_neighbors()->Array[Cell]:
		return [
			Cell.new(index_2d + Vector2(-1, 0), self),
			Cell.new(index_2d + Vector2(1, 0), self),
			Cell.new(index_2d + Vector2(0, -1), self),
			Cell.new(index_2d + Vector2(0, 1), self),
		];

static func generate_cells(
	_size: Vector2 = Vector2(3,3),
	cells: Array[Cell] = [Cell.new(Vector2(0,0))],
	current_cell: Cell = null
)->Array[Cell]:
	if current_cell == null:
		current_cell = cells[0];
	# setup all cardinal directions to check
	var grid_cell_neighbors: Array[Cell] = (
		current_cell.make_array_of_grid_cell_neighbors()
	);
	# remove closed cell neigbors to determine remaining open cells
	grid_cell_neighbors = grid_cell_neighbors.filter(func (open_cell):
		return !(
			(open_cell.index_2d.x < 0 or open_cell.index_2d.x > _size.x - 1) or
			(open_cell.index_2d.y < 0 or open_cell.index_2d.y > _size.y - 1)
		)
	).filter(func (open_cell):
		for cell in cells:
			if cell.index_2d == open_cell.index_2d:
				return false;
		return true;
	);
	# add random variation
	grid_cell_neighbors.shuffle();
	# iterate open cells, add to cells graph, call function recursively
	for grid_cell_neighbor in grid_cell_neighbors:
		# check that cell is still open
		var is_cell_open = true;
		for cell in cells:
			if cell.index_2d == grid_cell_neighbor.index_2d:
				is_cell_open = false;
		if !is_cell_open:
			continue;
		# Covnert vector back to cardinal
		var cardinal_direction_between_cells = (
			CardinalUtilities.get_cardinal_direction_from_vector(
				grid_cell_neighbor.index_2d - current_cell.index_2d
			)
		);
		var inverse_cardinal_direction_between_cells = (
			CardinalUtilities.get_inverse_cardinal_direction(
				cardinal_direction_between_cells
			)
		);
		current_cell.exits.append(cardinal_direction_between_cells);
		grid_cell_neighbor.exits.append(
			inverse_cardinal_direction_between_cells
		);
		grid_cell_neighbor.parent = current_cell;
		cells.append(grid_cell_neighbor);
		generate_cells(_size, cells, grid_cell_neighbor);
	return cells;
