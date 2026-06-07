extends Node2D

@onready var player: CharacterBody2D = $player
@onready var tile_map_layer: TileMapLayer = $worldMap/harvestables

# hover tileset to see id
const WILD_BERRIES_TILESET_SOURCE_ID = 6
const CROPS_TILESET_SOURCE_ID = 7

# growth stuff
const REGROW_TIME = 10.0 # seconds - todo make global
var regrow_timers: Dictionary = {}

# all harvestables
var harvest_data: Dictionary = {
	Vector2i(4, 0): {
		"empty_coords": Vector2i(4, 2),
		"source_id": WILD_BERRIES_TILESET_SOURCE_ID,
		"item_name": "wild_berries",
		"amount": 1
	},
	Vector2i(0, 0): {
		"empty_coords": Vector2i(1, 0),
		"source_id": CROPS_TILESET_SOURCE_ID,
		"item_name": "blueberries",
		"amount": 3
	},
	Vector2i(0, 1): {
		"empty_coords": Vector2i(1, 1),
		"source_id": CROPS_TILESET_SOURCE_ID,
		"item_name": "chilli_pepper",
		"amount": 1
	},
	Vector2i(0, 2): {
		"empty_coords": Vector2i(1, 2),
		"source_id": CROPS_TILESET_SOURCE_ID,
		"item_name": "strawberry",
		"amount": 1
	},
	Vector2i(0, 3): {
		"empty_coords": Vector2i(1, 3),
		"source_id": CROPS_TILESET_SOURCE_ID,
		"item_name": "carrot",
		"amount": 1
	}
}

func _ready() -> void:
	if Globals.target_transition_marker != "":
		var spawn_point = find_child(Globals.target_transition_marker)
		if spawn_point:
			player.global_position = spawn_point.global_position
			print("spawn at: ", spawn_point.name)
		else:
			print("error no spawn: ", Globals.target_transition_marker)
		Globals.target_transition_marker = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_harvest()

func _process(delta: float) -> void:
	# duplicate().keys() to avoid "dictionary changed during size iteration" error
	for cell in regrow_timers.keys().duplicate():
		regrow_timers[cell]["time"] -= delta
		if regrow_timers[cell]["time"] <= 0:
			regrow_crop(cell)

func try_harvest() -> void:
	var player_cell = tile_map_layer.local_to_map(tile_map_layer.to_local(player.global_position))
	
	var check_offsets = [
		Vector2i(0,0),    # current tile
		Vector2i(0,-1),   # up
		Vector2i(0,1),    # down
		Vector2i(-1,0),   # left
		Vector2i(1,0),    # right
		Vector2i(-1,-1), Vector2i(1,-1), # diagonal
		Vector2i(-1,1),  Vector2i(1,1)
	]
	
	for offset in check_offsets:
		var target_cell = player_cell + offset
		var current_tile_coords = tile_map_layer.get_cell_atlas_coords(target_cell)
		
		# if the key exists in the harvestables
		if harvest_data.has(current_tile_coords):
			harvest_tile(target_cell, current_tile_coords)
			break

func harvest_tile(cell_coords: Vector2i, atlas_coords: Vector2i) -> void:
	var data = harvest_data[atlas_coords]
	var item_name = data["item_name"]
	
	var target_item: ItemData = null
	for key in ItemDatabase.items.keys():
		if key.to_lower() == item_name.to_lower().strip_edges():
			target_item = ItemDatabase.items[key]
			break
			
	if target_item == null:
		push_error("harvest error: '" + item_name + "' was not found in ItemDatabase!")
		return

	if not Globals.has_empty_inventory_slot():
		print('inventory full!')
		return

	# update tile with empty version
	tile_map_layer.set_cell(cell_coords, data["source_id"], data["empty_coords"])
		
	# loop for multiple harvestables, ex: picking many berries at once
	for i in range(data["amount"]):
		Globals.add_item(target_item)
		
	# begin regrowing
	regrow_timers[cell_coords] = {
		"time": REGROW_TIME,
		"full_coords": atlas_coords,
		"source_id": data["source_id"]
	}

func regrow_crop(cell_coords: Vector2i) -> void:
	var timer_data = regrow_timers[cell_coords]
	
	# replace with the fully grown plant to harvest again
	tile_map_layer.set_cell(cell_coords, timer_data["source_id"], timer_data["full_coords"])
	regrow_timers.erase(cell_coords)
