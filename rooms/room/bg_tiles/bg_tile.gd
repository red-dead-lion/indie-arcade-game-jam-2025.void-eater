class_name BGTile;
extends StaticBody2D;

# Settings
@export var tile_textures: Array[Texture];

# Properties
@onready var sprite: Sprite2D = $Sprite2D;

# Timers
var tile_suck_up_timer = 0.2;
@export var c_tile_suck_up_timer = 0.0;

# Properties
var is_being_sucked_up = false;
var tile_being_sucked_up_original_position: Vector2;
var target_position: Vector2;

# Lifecycle
func _ready() -> void:
	sprite.texture = tile_textures.get(randi() % tile_textures.size())
	tile_being_sucked_up_original_position = global_position;

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return;
	if is_being_sucked_up:
		c_tile_suck_up_timer += delta;
		if c_tile_suck_up_timer > tile_suck_up_timer:
			RPC_remove_tile.rpc();
			c_tile_suck_up_timer = 0;
		global_position = lerp(
			tile_being_sucked_up_original_position,
			target_position,
			c_tile_suck_up_timer / tile_suck_up_timer
		);

# Methods
func begin_suck(to_position: Vector2, timer_length: float = tile_suck_up_timer):
	if is_being_sucked_up:
		return;
	is_being_sucked_up = true;
	target_position = to_position;
	tile_being_sucked_up_original_position = global_position;
	tile_suck_up_timer = timer_length;

# Network
@rpc('authority', 'call_local')
func RPC_remove_tile()->void:
	queue_free();
