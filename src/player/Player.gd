extends CharacterBody2D

@export var ACC := 100
@export var MAX_SPEED := 300
@export var FRICTION := 150

@onready var startPoint : Vector2
@onready var endPoint :  Vector2

@onready var animatedSprite := $AnimatedSprite
@onready var itemManager := $ItemManager

enum MovementState {
	IDLE,
	MOVE,
}
@export var mov_state := MovementState.IDLE
enum ItemState {
	IDLE,
	PRIMARY_ACTION,
	RELOAD,
	SECONDARY_ACTION,
}
@export var item_state := ItemState.IDLE
var movement: Vector2= Vector2.ZERO

var is_holding_shoot: bool = false
var _anim_name: StringName = &''

@onready var current_item = itemManager.current_item_i

func _ready() -> void:
	# _set_weapons_cooldown()
	mov_state = MovementState.IDLE
	item_state = ItemState.IDLE
	_update_animations()


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())

	movement = Vector2(
		Input.get_axis('ui_left', 'ui_right'),
		Input.get_axis('ui_up','ui_down')
	).normalized()

	if movement != Vector2.ZERO:
		velocity = velocity.move_toward(movement*MAX_SPEED, ACC*delta)
		mov_state = MovementState.MOVE
		_update_animations()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)

	move_and_slide()

	if velocity == Vector2.ZERO and mov_state != MovementState.IDLE:
		mov_state = MovementState.IDLE
		_update_animations()

	if Input.is_action_pressed('primary_action'):
		if item_state != ItemState.RELOAD:
			if itemManager.primary_action(mov_state == MovementState.MOVE):
				item_state = ItemState.PRIMARY_ACTION
				_update_animations()
				itemManager.is_holding_primary_action = true
	elif Input.is_action_just_released('primary_action'):
		itemManager.is_holding_primary_action = false

	# elif Input.is_action_pressed('secondary_action'):
	# 	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('exit'):
		get_tree().quit()

	elif event.is_action_pressed('reload'):
		if item_state != ItemState.RELOAD:
			if itemManager.reload():
				item_state = ItemState.RELOAD
				_update_animations()

	# Talvez essa lógica faça mais sentida dentro do itemManager
	elif event.is_action_pressed('secondary_action'):
		if current_item == Item.Type.KNIFE or current_item == Item.Type.FLARE_STICK:
			pass
		else:
			item_state = ItemState.SECONDARY_ACTION
			_update_animations()

	elif event.is_action_pressed('change_item'):
		var slot := event.as_text()
		print('change item to ', slot)
		_change_item(slot)
		item_state = ItemState.IDLE
		_update_animations()

	# Isso vai atrapalhar a animação para MovmementState?
	await animatedSprite.animation_finished
	if item_state != ItemState.IDLE:
		item_state = ItemState.IDLE
		_update_animations()


func _update_animations() -> void:
	print('_update_animations')
	_anim_name = _get_anim_name()

	if item_state == ItemState.IDLE:
		pass

	animatedSprite.play(_anim_name)

	if item_state != ItemState.IDLE:
		return

	match mov_state:
		MovementState.IDLE:
			animatedSprite.play(_anim_name)
		MovementState.MOVE:
			animatedSprite.play(_anim_name)


func _change_item(item: String) -> void:
	current_item = itemManager.change_weapon(item)
	_anim_name = _get_anim_name()
	animatedSprite.play(_anim_name)

	if current_item == Item.Type.KNIFE:
		$CollisionShape2D.rotation = deg_to_rad(-216.9)
	else:
		$CollisionShape2D.rotation = deg_to_rad(-129.4)


# FIXME: Aposto que é muito horrível em desempenho
func _get_anim_name() -> StringName:
	var item_state_str: String = ''
	if item_state == ItemState.IDLE and mov_state == MovementState.MOVE:
		item_state_str = 'Move'
	else:
		var sep_str: PackedStringArray = ItemState.keys()[item_state].capitalize().split(' ')
		item_state_str = ''.join(sep_str)
	var item_name = Item.Type.keys()[itemManager.current_item_i].capitalize()
	var anim_name = item_name + item_state_str
	return anim_name


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
	assert(shoot_animation_names.size() == itemManager.weapons.size())

	var weapon_index = 0
	for anim_name in shoot_animation_names:
		frames = animatedSprite.sprite_frames.get_frame_count(anim_name)
		# FIXME: BUGADO: a ordem(itemManager.weapons) != ordem(shoot_animation_names)
		cooldown = itemManager.weapons[weapon_index].cooldown
		fps = frames/cooldown

		animatedSprite.sprite_frames.set_animation_speed(anim_name, fps)
		print(anim_name)
		print('       frames ', frames)
		print('          fps ', fps)
		print('     cooldown ', cooldown)
		print()
		weapon_index += 1


