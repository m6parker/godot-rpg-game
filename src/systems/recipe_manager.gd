extends Node

var potion_recipes: Array[RecipeData] = []
var item_recipes: Dictionary = {}
const RECIPE_FILE_PATH = "res://src/systems/items_recipes.json"
const ITEMS_BASE_PATH = "res://Items/"

func _ready() -> void:
	load_potion_recipes_from_json("res://data/potion_recipes.json")
	load_item_recipes_from_json("res://data/item_recipes.json")

func load_potion_recipes_from_json(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("Recipe JSON file not found at: " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var raw_data = JSON.parse_string(json_text)
	if raw_data == null:
		push_error("Failed to parse recipes JSON.")
		return
		
	for recipe_data in raw_data:
		var new_recipe = RecipeData.new()
		
		# sort ingredients for matching
		var ingredient_list: Array[String] = []
		for ingredient in recipe_data["ingredients"]:
			ingredient_list.append(ingredient.to_lower().strip_edges())
		ingredient_list.sort()
		
		new_recipe.ingredients = ingredient_list
		
		if recipe_data["result"].size() > 0:
			new_recipe.result_item_name = recipe_data["result"][0].to_lower().strip_edges()
			
		potion_recipes.append(new_recipe)
		
	print("Successfully loaded ", potion_recipes.size(), " recipes into the cooking database!")
	

func load_item_recipes_from_json(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_error("Recipe file not found at: " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_ARRAY:
			for recipe in data:
				var ingredients = recipe.get("ingredients", [])
				var result = recipe.get("result", [])
				
				if ingredients.size() >= 2 and result.size() > 0:
					ingredients.sort()
					var recipe_key = ",".join(ingredients)
					
					item_recipes[recipe_key] = result[0]
		else:
			push_error("JSON data is not a list/array!")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())


func get_recipe_path(result_name: String) -> String:
	return ITEMS_BASE_PATH + result_name + ".tres"
