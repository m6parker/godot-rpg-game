extends Area2D

var bend_speed = 0.2
var back_speed = 1.5
@export var skew_value = 0.2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Calculate if player is coming from left or right
		var direction_x = sign(body.global_position.x - global_position.x)
		var target_skew = -direction_x * skew_value
		
		var tween = create_tween()
		
		# 1. Bend away from player
		tween.tween_property($Sprite2D, "skew", target_skew, bend_speed)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
			
		# 2. Spring back to center (chained automatically)
		tween.tween_property($Sprite2D, "skew", 0.0, back_speed)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_OUT)
