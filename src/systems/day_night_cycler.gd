extends CanvasModulate

@export var cycle_gradient: Gradient

func _ready() -> void:
	Globals.night_state_changed.connect(_on_night_state_changed)
	_on_night_state_changed(Globals.is_night)

func _process(_delta: float) -> void:
	if cycle_gradient:
		color = cycle_gradient.sample(Globals.time)

func _on_night_state_changed(is_night: bool) -> void:
	# show nighttime bugs and other nighttime events trigger here
	# todo - cricket sounds
	if is_night:
		print("is nighttime")
	else:
		print("is daytime")
