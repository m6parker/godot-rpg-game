extends Node2D

@onready var player: CharacterBody2D = $player
@onready var harvestables_tile_map_layer: TileMapLayer = $worldMap/harvestables
@onready var crops_tile_map_layer: TileMapLayer = $worldMap/crops

# tileset ids
const BUSHES_TILESET_SOURCE_ID = 6
const CROPS_TILESET_SOURCE_ID = 7

# growth stuff
const STAGE_GROWTH_TIME = 5.0 # seconds per stage
var regrow_timers: Dictionary = {}

# coords of plants
const CROP_DATABASE: Dictionary = {
	Vector2i(4, 0): {
		"crop_id": "wild_berries",
		"seed_name": "",
		"item_name": "wild_berries",
		"source_id": BUSHES_TILESET_SOURCE_ID,
		"harvest_amount": 1,
		"empty_coords": Vector2i(4, 2),
		"middle_coords": Vector2i(4, 1),
		"full_coords": Vector2i(4, 0)
	},
	Vector2i(2, 0): {
		"crop_id": "blueberries",
		"seed_name": "blueberries_seeds",
		"item_name": "blueberries",
		"source_id": CROPS_TILESET_SOURCE_ID,
		"harvest_amount": 3,
		"empty_coords": Vector2i(3, 0),
		"middle_coords": Vector2i(1, 0),
		"full_coords": Vector2i(2, 0)
	},
	Vector2i(2, 1): {
		"crop_id": "chilli_pepper",
		"seed_name": "chilli_pepper_seeds",
		"item_name": "chilli_pepper",
		"source_id": CROPS_TILESET_SOURCE_ID,
		"harvest_amount": 1,
		"empty_coords": Vector2i(3, 1),
		"middle_coords": Vector2i(1, 0),
		"full_coords": Vector2i(2, 1)
	},
	Vector2i(2, 2): {
		"crop_id": "strawberry",
		"seed_name": "strawberry_seeds",
		"item_name": "strawberry",
		"source_id": CROPS_TILESET_SOURCE_ID,
		"harvest_amount": 1,
		"empty_coords": Vector2i(3, 2),
		"middle_coords": Vector2i(1, 0),
		"full_coords": Vector2i(2, 2)
	},
	Vector2i(2, 3): {
		"crop_id": "carrot",
		"seed_name": "carrot_seeds",
		"item_name": "carrot",
		"source_id": CROPS_TILESET_SOURCE_ID,
		"harvest_amount": 1,
		"empty_coords": Vector2i(3, 3),
		"middle_coords": Vector2i(1, 0),
		"full_coords": Vector2i(2, 3)
	}
}

func _ready() -> void:
	if Globals.target_transition_marker != "":
		var spawn_point = find_child(Globals.target_transition_marker)
		if spawn_point:
			player.global_position = spawn_point.global_position
		else:
			print("error no spawn: ", Globals.target_transition_marker)
		Globals.target_transition_marker = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var equipped_item = Globals.get_equipped_item() 
		
		# check if equipping seeds
		var seed_crop_data = get_crop_data_by_seed(equipped_item.item_name if equipped_item else "")
		
		if seed_crop_data != null:
			try_plant(seed_crop_data)
		else:
			try_harvest()

func _process(delta: float) -> void:
	for cell in regrow_timers.keys().duplicate():
		regrow_timers[cell]["time"] -= delta
		if regrow_timers[cell]["time"] <= 0:
			advance_growth_stage(cell)

func try_harvest() -> void:
	var player_cell = harvestables_tile_map_layer.local_to_map(player.global_position - harvestables_tile_map_layer.global_position)
	
	var check_offsets = [
		Vector2i(0,0),    # current tile
		Vector2i(0,-1),   # up
		Vector2i(0,1),    # down
		Vector2i(-1,0),   # left
		Vector2i(1,0),    # right
		Vector2i(-1,-1), Vector2i(1,-1), 
		Vector2i(-1,1),  Vector2i(1,1)
	]
	
	for offset in check_offsets:
		var target_cell = player_cell + offset
		
		# check harvestables layer (wild)
		var h_coords = harvestables_tile_map_layer.get_cell_atlas_coords(target_cell)
		if CROP_DATABASE.has(h_coords):
			harvest_tile(target_cell, CROP_DATABASE[h_coords], harvestables_tile_map_layer)
			break
			
		# check crops layer (planted)
		var c_coords = crops_tile_map_layer.get_cell_atlas_coords(target_cell)
		if CROP_DATABASE.has(c_coords):
			harvest_tile(target_cell, CROP_DATABASE[c_coords], crops_tile_map_layer)
			break

func harvest_tile(cell_coords: Vector2i, crop_info: Dictionary, target_layer: TileMapLayer) -> void:
	var item_name = crop_info["item_name"]
	
	var target_item: ItemData = null
	for key in ItemDatabase.items.keys():
		if key.to_lower() == item_name.to_lower().strip_edges():
			target_item = ItemDatabase.items[key]
			break
			
	if target_item == null:
		push_error("error: '" + item_name + "' was not found in ItemDatabase!")
		return

	if not Globals.has_empty_inventory_slot():
		print('inventory full!')
		return

	# revert to harvested empty
	target_layer.set_cell(cell_coords, crop_info["source_id"], crop_info["empty_coords"])
		
	for i in range(crop_info["harvest_amount"]):
		Globals.add_item(target_item)
		
	# regrown from empty / harvested stage
	regrow_timers[cell_coords] = {
		"time": STAGE_GROWTH_TIME,
		"stage": 1, 
		"middle_coords": crop_info["middle_coords"],
		"full_coords": crop_info["full_coords"],
		"source_id": crop_info["source_id"],
		"layer": target_layer
	}
	
	
func try_plant(crop_info: Dictionary) -> void:
	var player_cell = crops_tile_map_layer.local_to_map(player.global_position - crops_tile_map_layer.global_position)
	var current_tile_coords = crops_tile_map_layer.get_cell_atlas_coords(player_cell)
	
	if current_tile_coords != Vector2i(-1, -1) or regrow_timers.has(player_cell):
		print("cannot plant here!")
		return
		
	crops_tile_map_layer.set_cell(player_cell, crop_info["source_id"], crop_info["middle_coords"])
	
	regrow_timers[player_cell] = {
		"time": STAGE_GROWTH_TIME,
		"stage": 1,
		"middle_coords": crop_info["middle_coords"],
		"full_coords": crop_info["full_coords"],
		"source_id": crop_info["source_id"],
		"layer": crops_tile_map_layer
	}
	
	# remove seeds from inventory
	# Globals.remove_equipped_item()
	print("planted ", crop_info["seed_name"], " at ", player_cell)

func advance_growth_stage(cell_coords: Vector2i) -> void:
	var timer_data = regrow_timers[cell_coords]
	var layer = timer_data["layer"]
	
	if timer_data["stage"] == 0:
		layer.set_cell(cell_coords, timer_data["source_id"], timer_data["middle_coords"])
		timer_data["stage"] = 1
		timer_data["time"] = STAGE_GROWTH_TIME 
	
	elif timer_data["stage"] == 1:
		layer.set_cell(cell_coords, timer_data["source_id"], timer_data["full_coords"])
		regrow_timers.erase(cell_coords)

# find crop based off seeds name
func get_crop_data_by_seed(seed_name: String) -> Variant:
	if seed_name == "": 
		return null
	for crop_pos in CROP_DATABASE:
		if CROP_DATABASE[crop_pos]["seed_name"] == seed_name:
			return CROP_DATABASE[crop_pos]
	return null
