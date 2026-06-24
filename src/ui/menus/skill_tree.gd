extends Control

@onready var branch_container: HBoxContainer = $TextureRect/branch_container

const JSON_FILE_PATH = "res://data/skills.json"

func _ready() -> void:
	# connect to global signal to update menu
	if has_node("/root/Globals"):
		Globals.skill_updated.connect(refresh_ui)
		
	refresh_ui()

func refresh_ui() -> void:
	# clear placeholders
	for child in branch_container.get_children():
		child.queue_free()
		
	load_and_build_ui()

func load_and_build_ui() -> void:
	# parse json file
	if not FileAccess.file_exists(JSON_FILE_PATH):
		push_error("missing json file " + JSON_FILE_PATH)
		return
		
	var file_text = FileAccess.get_file_as_string(JSON_FILE_PATH)
	var raw_data = JSON.parse_string(file_text)
	
	if not raw_data is Array:
		push_error("json data wrong format")
		return

	# loop thru data
	for item in raw_data:
		if item is Dictionary:
			for branch_name in item.keys():
				var skill_list = item[branch_name]
				create_branch_column(branch_name, skill_list)

# creates column per skill
func create_branch_column(branch_name: String, skills: Array) -> void:
	# create container
	var column = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_BEGIN
	column.add_theme_constant_override("separation", 20) # 20 pixels apart
	branch_container.add_child(column)
	
	# branch title
	var title_label = Label.new()
	title_label.text = branch_name
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title_label)
	
	# get players current level for this branch
	var upper_branch_name = branch_name.to_upper()
	var current_player_level: int = 0
	if has_node("/root/Globals") and Globals.playerSkills.has(upper_branch_name):
		current_player_level = Globals.playerSkills[upper_branch_name]
	
	# create button per skill tier
	for i in range(skills.size()):
		var skill_dict = skills[i] as Dictionary
		var skill_name = skill_dict.keys()[0]
		
		var skill_button = Button.new()
		skill_button.text = skill_name
		skill_button.custom_minimum_size = Vector2(120, 40) # button size
		
		# default unlocked values
		var is_unlocked = (current_player_level >= i)
		skill_button.disabled = not is_unlocked
		
		# pass skill info on button click
		skill_button.pressed.connect(func(): _on_skill_clicked(branch_name, skill_name))
		column.add_child(skill_button)
		
		# draw line for all buttons, not the last one
		if i < skills.size() - 1:
			var line = Line2D.new()
			line.width = 2
			line.default_color = Color.DARK_GRAY
			
			line.add_point(Vector2(60, 40))
			line.add_point(Vector2(60, 60))
			
			skill_button.add_child(line)


# skill button pressed
func _on_skill_clicked(branch: String, skill_name: String) -> void:
	print("clicked skill ", skill_name, " in branch ", branch)
	if "Globals" in self:
		print(Globals.playerSkills)
