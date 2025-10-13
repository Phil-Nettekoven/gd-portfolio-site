extends Node3D

@export var tile_scene:PackedScene
const WORLD_SCALE:int = 10
const TILE_WIDTH:int = 300
@export var world_size:int = 10
var world_tiles:Dictionary[Vector2i,Node3D] = {}

func _ready() -> void:
	UIMgr.mouse_needed = true
	UIMgr.delayed_mouse_grab = false
	init_world()

func init_world()->void:
	for x in range(world_size):
		for y in range(world_size):
			spawn_tile(Vector2i(x,y))

func spawn_tile(coords:Vector2i)->void:
	if world_tiles.has(coords):
		Globals.gprint("already generated "+str(coords))
		return
	
	var new_tile:Node3D = tile_scene.instantiate()
	new_tile.scale = Vector3(WORLD_SCALE,WORLD_SCALE,WORLD_SCALE)
	add_child(new_tile)
	
	var x_pos:int = TILE_WIDTH*coords.x
	var z_pos:int = TILE_WIDTH*coords.y
	new_tile.global_position = Vector3(x_pos, 0, z_pos)
	world_tiles[coords] = new_tile
	
	
func _process(_delta: float) -> void:
	pass
