extends Node

# stores parsed recipe data objects
var recipes: Array[RecipeData] = []

func _ready() -> void:
	load_recipes_from_json("res://data/potion_recipes.json")

func load_recipes_from_json(file_path: String) -> void:
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
			
		recipes.append(new_recipe)
		
	print("Successfully loaded ", recipes.size(), " recipes into the cooking database!")
