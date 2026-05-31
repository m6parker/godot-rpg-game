extends CanvasLayer

signal dialogue_finished
@onready var text_label: Label = $Panel/dialogue_text
@onready var panel: Panel = $Panel
var active_dialogue: Array[String] = []
var current_line: int = 0
var is_active: bool = false

func _ready() -> void:
	#box not visible when game starts
	panel.hide()

func start_dialogue(lines: Array[String]) -> void:
	if is_active:
		return
	active_dialogue = lines
	current_line = 0
	is_active = true
	panel.show()
	show_line()

func show_line() -> void:
	text_label.text = active_dialogue[current_line]

func advance_dialogue() -> void:
	current_line += 1
	
	if current_line >= active_dialogue.size():
		end_dialogue()
	else:
		show_line()

func end_dialogue() -> void:
	panel.hide()
	is_active = false
	dialogue_finished.emit()

func get_dialogue_by_id(npc_id: String) -> Array[String]:
	var file_path = "res://player/npc_dialogue.json"
	
	if not FileAccess.file_exists(file_path):
		push_error("npc dialogue json file not found at: " + file_path)
		return ["error missing file"]
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	# parse text into gdscript dictionary
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data = json.get_data()
		if data.has(npc_id):
			var lines: Array[String] = []
			for line in data[npc_id]:
				lines.append(str(line))
			return lines
		else:
			push_error("missing npc (" + npc_id + ") - not found in JSON.")
			return ["error no npc"]
	else:
		push_error("json parse error", json.get_error_message(), " at line ", json.get_error_line())
		return ["parse error"]
		
		
