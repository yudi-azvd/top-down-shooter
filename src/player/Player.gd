extends CharacterBody2D

@export var ACC := 100
@export var MAX_SPEED := 300
@export var FRICTION := 150

@onready var startPoint : Vector2
@onready var endPoint :  Vector2

@onready var animatedSprite := $AnimatedSprite
@onready var weaponManager := $WeaponManager
@onready var sfxHandgunReload := $SfxHandgunReload
@onready var sfxHandgunShot := $SfxHandgunShot

enum MovementState {
	IDLE,
	MOVE,
}
@export var mov_state := MovementState.IDLE

enum WeaponState {
	IDLE,
	SHOOT,
	RELOAD,
	MELEE,
}
@export var weapon_state := WeaponState.IDLE:
	set(new_state):
		weapon_state = new_state
		# print('changing weapon state to: ', WeaponState.keys()[new_state])

var movement := Vector2.ZERO
var shot_sfx_timer = 0
var last_shot_sfx = sfxHandgunShot

@onready var current_weapon = weaponManager.current_weapon_i

func _ready() -> void:
	# _set_weapons_cooldown()
	mov_state = MovementState.IDLE
	weapon_state = WeaponState.IDLE

func _physics_process(delta: float) -> void:
	shot_sfx_timer += delta
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

	if velocity == Vector2.ZERO and mov_state != MovementState.IDLE:
		mov_state = MovementState.IDLE

	_update_animations()

	# if Input.is_action_pressed('shoot'):
	# 	print('@@@ shoot')
	# 	if weapon_state != WeaponState.RELOAD and weapon_state != WeaponState.MELEE:
	# 		if current_weapon == WeaponManager.SelectedWeapon.RIFLE:
	# 			if weaponManager.shoot():
	# 				weapon_state = WeaponState.SHOOT
	# 				_play_sfx_handgun_shot()
	# 		else:
	# 			pass
	# elif Input.is_action_just_released('shoot'):
	# 	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('shoot', true):
		# print('@@@ shoot')
		if weapon_state != WeaponState.RELOAD and weapon_state != WeaponState.MELEE:
			if weaponManager.shoot():
				weapon_state = WeaponState.SHOOT
				_play_sfx_handgun_shot()

	# https://godotengine.org/qa/77484/how-do-i-detect-holding-down-the-mouse
	# if event is InputEventMouseButton:
	# 	print('111 shoot')
	# 	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
	# 		print('222 shoot')
	# 		if weapon_state != WeaponState.RELOAD and weapon_state != WeaponState.MELEE:
	# 			if weaponManager.shoot():
	# 				weapon_state = WeaponState.SHOOT
	# 				_play_sfx_handgun_shot()

	if event.is_action_pressed('reload'):
		if weapon_state != WeaponState.RELOAD:
			if weaponManager.reload():
				weapon_state = WeaponState.RELOAD
				sfxHandgunReload.play()

	elif event.is_action_pressed('melee'):
		weapon_state = WeaponState.MELEE

	if event.is_action_pressed('change_weapon'):
		var slot = event.as_text()
		_change_weapon(slot)
		weapon_state = WeaponState.IDLE

	_update_animations()

	# Isso vai atrapalhar a animação para MovmementState?
	await animatedSprite.animation_finished
	if weapon_state != WeaponState.IDLE:
		weapon_state = WeaponState.IDLE


func _update_animations():
	match weapon_state:
		WeaponState.IDLE:
			pass

		WeaponState.SHOOT:
			animatedSprite.pplay(_get_anim_name())

		WeaponState.RELOAD:
			animatedSprite.pplay(_get_anim_name())

		WeaponState.MELEE:
			animatedSprite.pplay(_get_anim_name())

	if weapon_state != WeaponState.IDLE:
		return

	match mov_state:
		MovementState.IDLE:
			animatedSprite.pplay(_get_anim_name())
		MovementState.MOVE:
			animatedSprite.pplay(_get_anim_name())

func _play_sfx_handgun_shot():
	if sfxHandgunShot.playing:
		var new_gun_shot: AudioStreamPlayer = sfxHandgunShot.duplicate()
		get_parent().add_child(new_gun_shot)
		new_gun_shot.play()
		# print('>>> time ', shot_sfx_timer)
		shot_sfx_timer = 0
		await new_gun_shot.finished
		new_gun_shot.queue_free()
	else:
		sfxHandgunShot.play()


func _change_weapon(weapon):
	# print('current weapon ', current_weapon)
	weaponManager.change_weapon(weapon)
	var anim_name = _get_anim_name()
	# print('changing animation to ', anim_name)
	animatedSprite.pplay(anim_name)


func _get_anim_name():
	var weapon_state_str = WeaponState.keys()[weapon_state].capitalize()
	var weapon_name = weaponManager.Weapon.Type.keys()[weaponManager.current_weapon_i].capitalize()
	var anim_name = weapon_name + weapon_state_str
	return anim_name

func _on_animated_sprite_animation_changed() -> void:
	# print('animation changed to ', animatedSprite.animation)
	pass


## Tem que fazer algo parecido pra animação de melee e reload
func _set_weapons_cooldown():
	var animation_names = animatedSprite.sprite_frames.get_animation_names()
	var shoot_animation_names = PackedStringArray()
	var frames := .0
	var fps := 0.0
	var cooldown := .0
	for anim_name in animation_names:
		if anim_name.ends_with('Shoot'):
			shoot_animation_names.append(anim_name)

	assert(shoot_animation_names.size() > 0)
	assert(shoot_animation_names.size() == weaponManager.weapons.size())

	var weapon_index = 0
	for anim_name in shoot_animation_names:
		frames = animatedSprite.sprite_frames.get_frame_count(anim_name)
		# FIXME: BUGADO: a ordem(weaponManager.weapons) != ordem(shoot_animation_names)
		cooldown = weaponManager.weapons[weapon_index].cooldown
		fps = frames/cooldown

		animatedSprite.sprite_frames.set_animation_speed(anim_name, fps)
		print(anim_name)
		print('       frames ', frames)
		print('          fps ', fps)
		print('     cooldown ', cooldown)
		print()
		weapon_index += 1
