extends CanvasLayer

@onready var panel = $Panel

func _ready():
	# show notification
	panel.modulate.a = 1.0 
	
	# create for 2 seconds
	var tween = create_tween()
	tween.tween_interval(2.0) 
	
	# fade modulate.a from 1.0 to 0.0 over 1 second
	tween.tween_property(panel, "modulate:a", 0.0, 1.0)
	
	# remove when done fading
	tween.tween_callback(queue_free)
