extends CharacterBody2D

@export var ACC := 100
@export var MAX_SPEED := 300
@export var FRICTION := 150

@onready var startPoint : Vector2
@onready var endPoint :  Vector2

@onready var animatedSprite := $AnimatedSprite
@onready var weaponManager := $WeaponManager

enum MovementState {
	IDLE,
	MOVE,
}
@export var mov_state := MovementState.IDLE

enum WeaponState {
	IDLE,
	RELOAD,
	SHOOT,
	MELEE,
}
@export var weapon_state := WeaponState.IDLE

var Bullet = preload('res://src/weapon/Bullet.tscn')
var movement := Vector2.ZERO

func _ready() -> void:
	_set_weapons_cooldown()
	mov_state = MovementState.IDLE
	weapon_state = WeaponState.IDLE

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())

	movement = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis('ui_up','ui_down')
	).normalized()

	if movement != Vector2.ZERO:
		velocity = velocity.move_toward(movement*MAX_SPEED, ACC*delta)
		mov_state = MovementState.MOVE
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)

	move_and_slide()

	if velocity == Vector2.ZERO:
		mov_state = MovementState.IDLE

	_update_state()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('shoot'):
		if weapon_state != WeaponState.RELOAD and weapon_state != WeaponState.MELEE:
			if weaponManager.shoot():
				weapon_state = WeaponState.SHOOT
	elif event.is_action_pressed('reload'):
		if weaponManager.reload():
			weapon_state = WeaponState.RELOAD
	elif event.is_action_pressed('melee'):
		weapon_state = WeaponState.MELEE

    # Isso vai atrapalhar a animação para MovmementState?
	await animatedSprite.animation_finished
	weapon_state = WeaponState.IDLE

	_update_state()


func _update_state():
	match weapon_state:
		WeaponState.IDLE:
			pass
		WeaponState.SHOOT:
			animatedSprite.play('HandgunShoot')
		WeaponState.RELOAD:
			animatedSprite.play('HandgunReload')
		WeaponState.MELEE:
			animatedSprite.play('HandgunMelee')

	if weapon_state != WeaponState.IDLE:
		return

	match mov_state:
		MovementState.IDLE:
			animatedSprite.play('HandgunIdle')
		MovementState.MOVE:
			animatedSprite.play('HandgunMove')

func _on_animated_sprite_animation_changed() -> void:
	print('animation changed to ', animatedSprite.animation)

## Tem que fazer algo parecido pra animação de melee e reload
func _set_weapons_cooldown():
	var animation_names = animatedSprite.sprite_frames.get_animation_names()
	var shoot_animation_names = PackedStringArray()
	var frames := .0
	var fps = 0
	var anim_duration := .0
	for anim_name in animation_names:
		if anim_name.ends_with('Shoot'):
			shoot_animation_names.append(anim_name)

	assert(shoot_animation_names.size() > 0)
	for anim_name in shoot_animation_names:
		fps = animatedSprite.sprite_frames.get_animation_speed(anim_name)
		frames = animatedSprite.sprite_frames.get_frame_count(anim_name)
		anim_duration = frames/fps
		weaponManager.handgun_cooldown = anim_duration
		# print(anim_name)
		# print('       frames ', frames)
		# print('          fps ', fps)
		# print('anim_duration ', anim_duration)
		# print()
