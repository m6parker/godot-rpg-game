extends Node2D

@onready var player: CharacterBody2D = $player
@onready var tile_map_layer: TileMapLayer = $worldMap/harvestables
@export var berry_resource: Resource = preload("res://Items/wildberries.tres")
@export var berry_amount: int = 1

#hover tileset to see id - bushes tileset
const TILESET_SOURCE_ID = 6
#location of tiles in atlas
const FULL_BUSH_COORDS = Vector2i(4, 0)
const EMPTY_BUSH_COORDS = Vector2i(4, 2)
const REGROW_TIME = 10.0 #seconds - todo make global
var regrow_timers: Dictionary = {}

func _ready() -> void:
	if Globals.target_transition_marker != "":
		var spawn_point = find_child(Globals.target_transition_marker)
		
		if spawn_point:
			player.global_position = spawn_point.global_position
			print("spawn at: ", spawn_point.name)
		else:
			print("Error: no marker: ", Globals.target_transition_marker)
			
		Globals.target_transition_marker = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_harvest_bush()

func _process(delta: float) -> void:
	for cell in regrow_timers.keys():
		regrow_timers[cell] -= delta
		if regrow_timers[cell] <= 0:
			regrow_bush(cell)

func try_harvest_bush() -> void:
	# player cell location is standing on
	var player_cell = tile_map_layer.local_to_map(tile_map_layer.to_local(player.global_position))
	
	# check cells around the player
	var check_offsets = [
		Vector2i(0,0),   # current tile
		Vector2i(0,-0.5),  # up
		Vector2i(0,0.5),   # down
		Vector2i(-0.5,0),  # left
		Vector2i(0.5,0),   # right
		Vector2i(-0.5,-0.5), Vector2i(0.5,-0.5), # diagonal
		Vector2i(-0.5,0.5),  Vector2i(0.5,0.5)
	]
	
	for offset in check_offsets:
		var target_cell = player_cell + offset
		var current_tile_coords = tile_map_layer.get_cell_atlas_coords(target_cell)
		
		# if a harvestable bush is within reach
		if current_tile_coords == FULL_BUSH_COORDS:
			harvest_tile(target_cell)
			break

func harvest_tile(cell_coords: Vector2i) -> void:
	# update bush with empty looking bush
	tile_map_layer.set_cell(cell_coords, TILESET_SOURCE_ID, EMPTY_BUSH_COORDS)
	
	# look for empty inventory slot
	var open_slot_index = Globals.player_inventory.find(null)
	
	# if inventory is full
	if open_slot_index == -1:
		print('inventory full!')
		return
		
	# move item in inventory and update inventory ui
	Globals.player_inventory[open_slot_index] = berry_resource
	Globals.inventory_updated.emit()
	
	# beegin counter for regrowing bushes
	regrow_timers[cell_coords] = REGROW_TIME

func regrow_bush(cell_coords: Vector2i) -> void:
	tile_map_layer.set_cell(cell_coords, TILESET_SOURCE_ID, FULL_BUSH_COORDS)
	regrow_timers.erase(cell_coords)
