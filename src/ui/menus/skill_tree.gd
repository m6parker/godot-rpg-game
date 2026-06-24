extends Control

@onready var branch_container: HBoxContainer = $TextureRect/branch_container
const JSON_FILE_PATH = "res://data/skills.json"

# tracks skill progression
# todo: move to globals for save/loading
var purchased_skills: Array[String] = []

func _ready() -> void:
	if has_node("/root/Globals"):
		Globals.skill_updated.connect(refresh_ui)
		
	refresh_ui()

func refresh_ui() -> void:
	for child in branch_container.get_children():
		child.queue_free()
		
	load_and_build_ui()

func load_and_build_ui() -> void:
	if not FileAccess.file_exists(JSON_FILE_PATH):
		push_error("missing json file " + JSON_FILE_PATH)
		return
		
	var file_text = FileAccess.get_file_as_string(JSON_FILE_PATH)
	var raw_data = JSON.parse_string(file_text)
	
	if not raw_data is Array:
		push_error("json data wrong format")
		return

	for item in raw_data:
		if item is Dictionary:
			for branch_name in item.keys():
				var skill_list = item[branch_name]
				create_branch_column(branch_name, skill_list)


# creates column per skill
func create_branch_column(branch_name: String, skills: Array) -> void:
	var column = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_BEGIN
	column.add_theme_constant_override("separation", 20)
	branch_container.add_child(column)
	
	var upper_branch_name = branch_name.to_upper() 
	var current_player_points: int = 0
	if has_node("/root/Globals") and Globals.playerSkills.has(upper_branch_name):
		current_player_points = Globals.playerSkills[upper_branch_name]
	
	var title_label = Label.new()
	title_label.text = upper_branch_name
	# title_label.text = upper_branch_name + "\n(" + str(current_player_points) + " point available)"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title_label)
	
	var previous_skill_purchased = true
	
	for i in range(skills.size()):
		var skill_name = skills[i] as String
		var skill_button = Button.new()
		skill_button.text = skill_name
		skill_button.custom_minimum_size = Vector2(120, 40)
		
		var cost_to_upgrade = 1 if i == 0 else i * 5
		var has_enough_points = current_player_points >= cost_to_upgrade
		var is_already_purchased = purchased_skills.has(skill_name)
		
		if is_already_purchased:
			skill_button.disabled = true
			#skill_button.text = skill_name
			skill_button.self_modulate = Color.GREEN
		elif previous_skill_purchased and has_enough_points:
			skill_button.disabled = false
		else:
			skill_button.disabled = true
				
		skill_button.pressed.connect(func(): _on_skill_clicked(upper_branch_name, skill_name))
		column.add_child(skill_button)
		
		if i < skills.size() - 1:
			var line = Line2D.new()
			line.width = 2
			var next_skill_cost = (i + 1) * 5
			var next_skill_affordable = current_player_points >= next_skill_cost
			# connector line will only be green is the skill is already unlocked and the next one is available
			if is_already_purchased and next_skill_affordable:
				line.default_color = Color.GREEN
			else:
				line.default_color = Color.DARK_GRAY
			line.add_point(Vector2(60, 40))
			line.add_point(Vector2(60, 60))
			skill_button.add_child(line)
			
		previous_skill_purchased = is_already_purchased

# skill button pressed
func _on_skill_clicked(branch: String, skill_name: String) -> void:
	if has_node("/root/Globals"):
		var upper_branch = branch.to_upper()
		if Globals.playerSkills.has(upper_branch):
			purchased_skills.append(skill_name)
			# refresh ui
			Globals.skill_updated.emit()
