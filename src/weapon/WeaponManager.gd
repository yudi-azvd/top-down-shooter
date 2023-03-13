class_name WeaponManager
extends Node2D

@onready var endPoint = $EndPoint
@onready var startPoint = $StartPoint
@onready var root := get_tree().get_root()

var Bullet = preload('res://src/weapon/Bullet.tscn')

var bullet_direction := Vector2.ZERO

var handgun = Weapon.new()
var rifle = Weapon.new()
var weapons: Array[Weapon] = [handgun, rifle]
enum SelectedWeapon {
	HANDGUN,
	RIFLE,
}
@export var current_weapon: Weapon = handgun
var current_weapon_i := SelectedWeapon.HANDGUN

func _ready() -> void:
	handgun.cooldown = 0.1481
	handgun.bullets_per_clip = 12
	handgun.bullets = handgun.bullets_per_clip
	handgun.clips = 4

	rifle.cooldown = 0.1036
	rifle.bullets_per_clip = 25
	rifle.bullets = rifle.bullets_per_clip
	rifle.clips = 4


func _process(delta: float) -> void:
	handgun.timer += delta
	rifle.timer += delta

func change_weapon(target_weapon: String):
	var i = int(target_weapon) - 1
	current_weapon = weapons[i]
	current_weapon_i = i
	# print('changed weapon to ', i, current_weapon)

func can_shoot() -> bool:
	if current_weapon.timer < current_weapon.cooldown:
		return false
	if current_weapon.bullets <= 0:
		return false
	return true

func shoot() -> bool:
	if not can_shoot():
		return false

	current_weapon.bullets -= 1
	current_weapon.timer = 0

	bullet_direction = (endPoint.global_position - startPoint.global_position).normalized()
	var bullet = Bullet.instantiate()

	root.add_child(bullet)
	bullet.global_position = endPoint.global_position

	# FIXME: Rotation e direction têm offset entre si??
	bullet.rotation = PI/2 + bullet_direction.angle()
	bullet.direction = bullet_direction

	return true

func reload() -> bool:
	if current_weapon.clips <= 0:
		return false

	current_weapon.bullets = current_weapon.bullets_per_clip
	current_weapon.clips -= 1
	return true
