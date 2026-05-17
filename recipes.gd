extends Node

# recipes sorted by player level
#	ex: level 1 player can craft with only 2 items
#	gets more complex as player levels up

const ITEM_PATH = "res://Items/"
const FILE_EXTENTION = ".tres"

func get_recipe_path(result_name: String) -> String:
	return ITEM_PATH + result_name + FILE_EXTENTION
	
# items sorted by type
# todo: maybe use enums
const BLUEJAY_FEATHER = "bluejay_feather"
const BUMBLEBEE = "bumblebee"
const HONEY_MUSHROOM = "honey_mushroom"
const MAPLE_LEAF = "maple_leaf"
const MONARCH_BUTTERFLY = "monarch_butterfly"
const MUSHROOM = "mushroom"
const OAK_LEAF = "oak_leaf"
const PINECOMB = "pinecomb"
const ROSE_PETAL = "rose_petal"

# keys gotta be alphetical and all items need to be lowercase strings
# todo: will become recipes_level_one
var recipes = {
	BUMBLEBEE + "," + MUSHROOM: HONEY_MUSHROOM,
	OAK_LEAF + "," + ROSE_PETAL: MAPLE_LEAF,
	BLUEJAY_FEATHER + "," + PINECOMB: MONARCH_BUTTERFLY
}
