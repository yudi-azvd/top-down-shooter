extends KinematicBody2D

enum Legs {
	IDLE,
	WALKING,
	RUNNING,
	STRAFFING,
}

enum Torso {
	IDLE,
	RELOADING,
	SHOOTING,
}

enum SelectedItem {
#	KNIFE,
	HANDGUN,
#	FLASHLIGHT,
#	SHOTGUN,
	RIFLE,
}


onready var animatedSpriteTorso = $AnimatedSpriteTorso
onready var animatedSpriteLegs = $AnimatedSpriteLegs

var ACC := 800
var FRICTION := 1000
export(int) var MAX_WALK_SPEED := 200
export(int) var MAX_WALK_SPEED_BACKWARDS := 150
export(Vector2) var movement_input := Vector2.ZERO
export(Vector2) var direction_input := Vector2.RIGHT
var velocity := Vector2.ZERO
var shoot_count := 0

var legs_state = Legs.IDLE
var torso_state = Torso.IDLE
var selected_item = SelectedItem.HANDGUN
var items_length = SelectedItem.keys().size()

var diff := .0
var diff_deg := .0
var cos_diff := .0

func _ready() -> void:
	input_pickable = true
	animatedSpriteTorso.play('handgun-idle')
	animatedSpriteLegs.play('idle')
	velocity = Vector2.ZERO
	selected_item = SelectedItem.HANDGUN
	look_at_mouse()
	
func _physics_process(delta: float) -> void:
	look_at_mouse()
	
	var input_x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	var input_y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	movement_input = Vector2(input_x, input_y).normalized()
	
	if movement_input != Vector2.ZERO:
		diff = movement_input.angle() - rotation
		diff_deg = rad2deg(diff)
		cos_diff = cos(diff)
		var tol = 1-cos(PI/4)
		if 1 - tol < cos_diff and cos_diff < 1 + tol:
			animatedSpriteLegs.speed_scale = 1
			velocity = velocity.move_toward(movement_input*MAX_WALK_SPEED, ACC*delta)
			animatedSpriteLegs.play('walk')
		elif -1 - tol < cos_diff and cos_diff < -1 + tol:
			animatedSpriteLegs.speed_scale = 0.8
			velocity = velocity.move_toward(movement_input*MAX_WALK_SPEED_BACKWARDS, ACC*delta)
			animatedSpriteLegs.play('walk', true)
		elif 0 < diff_deg and diff_deg < 180:
			animatedSpriteLegs.speed_scale = 1
			velocity = velocity.move_toward(movement_input*MAX_WALK_SPEED, ACC*delta)
			animatedSpriteLegs.play('strafe-right')
		else:
			animatedSpriteLegs.speed_scale = 1
			velocity = velocity.move_toward(movement_input*MAX_WALK_SPEED, ACC*delta)
			animatedSpriteLegs.play('strafe-left')
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
	
	velocity = move_and_slide(velocity)
	if velocity == Vector2.ZERO:
		animatedSpriteLegs.play('idle')

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_at_mouse()
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		shoot()
	
	if Input.is_action_just_released('reload'):
		reload()

	if Input.is_action_just_released('switch_selected_item'):
		switch_selected_item()
	
func reload():
	if animatedSpriteTorso.animation == concat_curr_selected_item('reload'):
		return

	animatedSpriteTorso.play(concat_curr_selected_item('reload'))
	yield(animatedSpriteTorso, 'animation_finished')
	if legs_state == Legs.WALKING or legs_state == Legs.RUNNING:
		animatedSpriteTorso.play(concat_curr_selected_item('walk'))
	else:
		animatedSpriteTorso.play(concat_curr_selected_item('idle'))

func shoot():
	if animatedSpriteLegs.animation == concat_curr_selected_item('shoot'):
		return

	shoot_count += 1
	animatedSpriteTorso.play(concat_curr_selected_item('shoot'))
	yield(animatedSpriteTorso, 'animation_finished')
	if legs_state == Legs.WALKING or legs_state == Legs.RUNNING:
		animatedSpriteTorso.play(concat_curr_selected_item('walk'))
	else:
		animatedSpriteTorso.play(concat_curr_selected_item('idle'))

func switch_selected_item():
	selected_item = (selected_item + 1) % items_length
	animatedSpriteTorso.play(concat_curr_selected_item('idle'))

func concat_curr_selected_item(animation: String) -> String:
	return '%s-%s' % [SelectedItem.keys()[selected_item].to_lower(), animation]
	
func look_at_mouse():
	look_at(get_global_mouse_position())

func _process(_delta: float) -> void:
	update()

func _draw() -> void:
	draw_line(Vector2.ZERO, get_local_mouse_position().normalized()*200, Color.white, 2)
	draw_line(Vector2.ZERO, direction_input*100, Color.blue, 2)
	draw_line(Vector2.ZERO, velocity.normalized().rotated(-rotation)*200, Color.red, 2)
