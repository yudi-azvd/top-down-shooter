extends CharacterBody2D

@export var ACC := 100
@export var MAX_SPEED := 300
@export var FRICTION := 150

@onready var startPoint : Vector2
@onready var endPoint :  Vector2

@onready var bulletManager := $BulletManager

var Bullet = preload('res://src/bullet/Bullet.tscn')

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	var movement := Vector2.ZERO
	
	movement = Vector2(
		Input.get_axis("ui_left", "ui_right"), 
		Input.get_axis('ui_up','ui_down')
	).normalized()
		
	if movement != Vector2.ZERO:
		velocity = velocity.move_toward(movement*MAX_SPEED, ACC*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('shoot'):
		bulletManager.shoot()

