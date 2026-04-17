extends CharacterBody2D


@export var move_speed: float = 100
@onready var animatedSprite = $AnimatedSprite2D
@onready var notebook: Panel = $CanvasLayer/notebook
@onready var inventory: Panel = $CanvasLayer/inventory


	
func openNotebook() -> void:
	if notebook.visible == false:
		notebook.visible = true
	else:
		notebook.visible = false
		
func openInventory() -> void:
	if inventory.visible == false:
		inventory.visible = true
	else:
		inventory.visible = false
		

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("notebook"):
		openNotebook()
	elif Input.is_action_just_pressed("inventory"):
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


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
