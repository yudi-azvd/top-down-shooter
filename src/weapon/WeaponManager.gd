@tool
extends Node2D

@onready var root := get_tree().get_root()
@onready var endPoint: Marker2D = $EndPoint
var startPoint: Vector2 = Vector2.ZERO

signal weapon_shot(weapon: Weapon.Type, remaining_bullets: int)
signal weapon_changed(weapon: Weapon.Type)
signal weapon_reloaded(weapon: Weapon.Type, bullets: int, magazines: int)

var Bullet = preload('res://src/weapon/Bullet.tscn')

var bullet_direction := Vector2.ZERO

class Weapon:
	var cooldown: float = 1
	var timer : float = 0.0
	var bullets_per_magazine: int = 1
	var bullets: int = bullets_per_magazine
	var magazines: int = 1
	var type = Type

	enum Type {
		RIFLE,
		HANDGUN,
		KNIFE,
	}

var handgun = Weapon.new()
var rifle = Weapon.new()
var knife = Weapon.new()
var weapons: Array[Weapon] = [rifle, handgun, knife]
var current_weapon: Weapon = handgun
var current_weapon_i: Weapon.Type = Weapon.Type.HANDGUN

var bullet_positions_dict = {
	rifle = Vector2(196, 32),
	handgun = Vector2(142, 42),
}

func _ready() -> void:
	_update_weapon_endpoint(current_weapon_i)

	handgun.cooldown = 0.1481
	handgun.bullets_per_magazine = 12
	handgun.bullets = handgun.bullets_per_magazine
	handgun.magazines = 4
	handgun.type = Weapon.Type.HANDGUN

	rifle.cooldown = 0.1
	rifle.bullets_per_magazine = 30
	rifle.bullets = rifle.bullets_per_magazine
	rifle.magazines = 3
	rifle.type = Weapon.Type.RIFLE

	knife.cooldown = 0.2
	knife.type = Weapon.Type.KNIFE

func _process(delta: float) -> void:
	handgun.timer += delta
	rifle.timer += delta

func can_shoot() -> bool:
	if current_weapon.timer < current_weapon.cooldown:
		return false
	if current_weapon.bullets <= 0:
		return false
	return true

func shoot(moving: bool = false) -> bool:
	if not can_shoot():
		return false

	if current_weapon.type == Weapon.Type.KNIFE:
		print('>>> knife attack!!')
		return true

	current_weapon.bullets -= 1
	current_weapon.timer = 0

	bullet_direction = (endPoint.global_position - to_global(startPoint)).normalized()
	var bullet = Bullet.instantiate()

	root.add_child(bullet)
	bullet.global_position = endPoint.global_position

	# FIXME: Rotation e direction têm offset entre si??
	bullet.rotation = PI/2 + bullet_direction.angle()
	bullet.direction = bullet_direction

	emit_signal('weapon_shot', current_weapon_i, current_weapon.bullets)
	return true

func reload() -> bool:
	if current_weapon.magazines <= 0:
		return false

	if current_weapon.bullets == current_weapon.bullets_per_magazine:
		return false

	current_weapon.bullets = current_weapon.bullets_per_magazine
	current_weapon.magazines -= 1

	emit_signal('weapon_reloaded', current_weapon_i, current_weapon.bullets, current_weapon.magazines)
	return true

func change_weapon(target_weapon: String):
	var weapon_i = int(target_weapon) - 1
	if weapon_i == current_weapon_i:
		return
	current_weapon = weapons[weapon_i]
	current_weapon_i =  weapon_i as Weapon.Type

	_update_weapon_endpoint(current_weapon_i)

func _update_weapon_endpoint(weapon: Weapon.Type):
	if weapon == Weapon.Type.RIFLE:
		endPoint.position = bullet_positions_dict.rifle
	elif weapon == Weapon.Type.HANDGUN:
		endPoint.position = bullet_positions_dict.handgun
	startPoint = Vector2(endPoint.position.x - 10, endPoint.position.y)

