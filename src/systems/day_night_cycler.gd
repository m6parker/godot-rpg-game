extends CanvasModulate

@export var day_duration: float = 120.0 #seconds
@export var cycle_gradient: Gradient

var time: float = 0.5
var is_night: bool = false 

func _process(delta: float) -> void:
	time += delta / day_duration
	if time >= 1.0:
		time = 0.0
		
	if cycle_gradient:
		color = cycle_gradient.sample(time)
	
	var new_night_state = (time < 0.2 or time > 0.8)
	if new_night_state != is_night:
		is_night = new_night_state
