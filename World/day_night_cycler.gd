#extends CanvasModulate
#
#@export var day_duration: float = 60.0 #second
#
#@export var cycle_gradient: Gradient
##current time
#var time: float = 0.0
#
#func _process(delta: float) -> void:
	#time += delta / day_duration
	#if time >= 1.0:
		#time = 0.0
	#if cycle_gradient:
		#color = cycle_gradient.sample(time)

extends CanvasModulate

@export var day_duration: float = 60.0 
@export var cycle_gradient: Gradient

var time: float = 0.0
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
