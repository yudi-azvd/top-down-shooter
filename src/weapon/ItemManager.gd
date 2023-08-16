@tool
extends Node2D

@onready var weaponSfxManager = $WeaponSfxManager
@onready var root := get_tree().get_root()
@onready var endPoint: Marker2D = $EndPoint
var startPoint: Vector2 = Vector2.ZERO

signal weapon_shot(weapon: Item.Type, remaining_bullets: int)
signal weapon_changed(weapon: Item.Type)
signal weapon_reloaded(weapon: Item.Type, bullets: int, magazines: int)

var Bullet = preload('res://src/weapon/Bullet.tscn')

var bullet_direction := Vector2.ZERO
var rng = RandomNumberGenerator.new()
var deviation: float = 0

var handgun = Item.new()
var rifle = Item.new()
var knife = Item.new()
var flare_sticks = Item.new()
var weapons: Array[Item] = [rifle, handgun, knife]
var current_item: Item = handgun
var current_item_i: Item.Type = Item.Type.HANDGUN
var is_holding_primary_action: bool = false

var bullet_positions_dict = {
	rifle = Vector2(196, 32),
	handgun = Vector2(142, 42),
}


func _ready() -> void:
	_update_weapon_endpoint(current_item_i)
	weaponSfxManager.change_weapon(current_item_i)

	handgun.cooldown = 0.1481
	handgun.bullets_per_magazine = 12
	handgun.bullets = handgun.bullets_per_magazine
	handgun.magazines = 4
	handgun.type = Item.Type.HANDGUN

	rifle.cooldown = 0.07
	rifle.bullets_per_magazine = 30
	rifle.bullets = rifle.bullets_per_magazine
	rifle.magazines = 3
	rifle.type = Item.Type.RIFLE
	rifle.is_primary_action_continuous = true

	knife.cooldown = 0.2
	knife.type = Item.Type.KNIFE
	knife.is_primary_action_continuous = false

	flare_sticks.count = 1
	flare_sticks.cooldown = 0.5
	flare_sticks.type = Item.Type.FLARE_STICK


func _process(delta: float) -> void:
	handgun.timer += delta
	rifle.timer += delta
	knife.timer += delta


func primary_action(moving: bool) -> bool:
	if current_item.type == Item.Type.KNIFE:
		return true

	if current_item.type == Item.Type.RIFLE or current_item.type == Item.Type.HANDGUN:
		if _can_shoot():
			_shoot(moving)
		else:
			return false

	return true


func secondary_action() -> void:
	pass


func _can_shoot() -> bool:
	if not current_item.is_primary_action_continuous and is_holding_primary_action:
		return false
	if current_item.timer < current_item.cooldown:
		return false
	if current_item.bullets <= 0:
		return false
	return true


func _shoot(moving: bool = false) -> bool:
	current_item.bullets -= 1
	current_item.timer = 0

	if moving:
		deviation = 0.08
	else:
		deviation = 0.0

	bullet_direction = (endPoint.global_position - to_global(startPoint))\
		.normalized()\
		.rotated(rng.randf_range(-deviation, deviation))
	var bullet = Bullet.instantiate()

	root.add_child(bullet)
	bullet.global_position = endPoint.global_position

	# FIXME: Rotation e direction têm offset entre si??
	bullet.rotation = PI/2 + bullet_direction.angle()
	bullet.direction = bullet_direction

	weapon_shot.emit(current_item_i, current_item.bullets)
	weaponSfxManager.play_shot()
	return true


func reload() -> bool:
	if current_item.magazines <= 0:
		return false

	if current_item.bullets == current_item.bullets_per_magazine:
		return false

	current_item.bullets = current_item.bullets_per_magazine
	current_item.magazines -= 1

	weapon_reloaded.emit(current_item_i, current_item.bullets, current_item.magazines)
#	sfxHandgunReload.play()
	weaponSfxManager.play_reload()
	return true


func change_weapon(target_weapon: String) -> Item.Type:
	var weapon_i = int(target_weapon) - 1
	if weapon_i == current_item_i:
		return current_item_i
	current_item = weapons[weapon_i]
	current_item_i = weapon_i as Item.Type

	_update_weapon_endpoint(current_item_i)
	weaponSfxManager.change_weapon(current_item_i)
	return current_item_i


func _update_weapon_endpoint(weapon: Item.Type):
	match weapon:
		Item.Type.RIFLE:
			endPoint.position = bullet_positions_dict.rifle
		Item.Type.HANDGUN:
			endPoint.position = bullet_positions_dict.handgun
		_:
			endPoint.position = Vector2.ZERO
			# push_error('Item not found: ', weapon)

	startPoint = Vector2(endPoint.position.x - 10, endPoint.position.y)
