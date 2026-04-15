extends CharacterBody2D


@export var move_speed: float = 100
@onready var animatedSprite = $AnimatedSprite2D
@onready var inventory: Panel = $CanvasLayer/inventory

	
func openInventory() -> void:
	print("inventory: ", inventory)
	if inventory.visible == false:
		inventory.visible = true
		print("open inventory")
	else:
		inventory.visible = false
		print("close inventory")	
		

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		openInventory()
		
	var inputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	velocity = inputDirection * move_speed

	if inputDirection.length() > 0:
		animatedSprite.play("walk_right")
		#flip the walking animation if walking left
		animatedSprite.flip_h = inputDirection.x < 0
	else:
		animatedSprite.play("idle")

	move_and_slide()
