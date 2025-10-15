class_name CardinalUtilities;

enum Direction {
	Up = 0,
	Down = 1,
	Left = 2,
	Right = 3,
	Undefined = 4,
};

const ALL_DIRECTIONS = [
	Direction.Up,
	Direction.Right,
	Direction.Down,
	Direction.Left,
];

static func cardinal_direction_to_vector(cardinal_direction: Direction):
	match cardinal_direction:
		Direction.Up:
			return Vector2(-1, 0)
		Direction.Down:
			return Vector2(1, 0)
		Direction.Left:
			return Vector2(0, -1)
		Direction.Right:
			return Vector2(0, 1)

static func get_inverse_cardinal_direction(
	cardinal_direction: Direction
)->Direction:
	match cardinal_direction:
		Direction.Up:
			return Direction.Down;
		Direction.Down:
			return Direction.Up;
		Direction.Left:
			return Direction.Right;
		Direction.Right:
			return Direction.Left;
	return Direction.Undefined;

static func get_cardinal_direction_from_vector(
	direction_vector: Vector2,
)->Direction:
	match direction_vector:
		Vector2.UP:
			return Direction.Up;
		Vector2.DOWN:
			return Direction.Down;
		Vector2.LEFT:
			return Direction.Left;
		Vector2.RIGHT:
			return Direction.Right;
	return Direction.Undefined;
