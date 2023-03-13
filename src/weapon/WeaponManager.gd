extends Node2D

@onready var endPoint = $EndPoint
@onready var startPoint = $StartPoint
@onready var root := get_tree().get_root()

signal weapon_shot(weapon: Weapon.Type, remaining_bullets: int)
signal weapon_changed(weapon: Weapon.Type)
signal weapon_reloaded(weapon: Weapon.Type, bullets: int, clips: int)

var Bullet = preload('res://src/weapon/Bullet.tscn')

var bullet_direction := Vector2.ZERO

class Weapon:
	var cooldown = 1
	var timer = 0.0
	var bullets_per_clip = 1
	var bullets = bullets_per_clip
	var clips = 1
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
var current_weapon_i := Weapon.Type.HANDGUN

func _ready() -> void:
	handgun.cooldown = 0.1481
	handgun.bullets_per_clip = 12
	handgun.bullets = handgun.bullets_per_clip
	handgun.clips = 4
	handgun.type = Weapon.Type.HANDGUN

	rifle.cooldown = 0.1
	rifle.bullets_per_clip = 30
	rifle.bullets = rifle.bullets_per_clip
	rifle.clips = 3
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

func shoot() -> bool:
	if not can_shoot():
		return false

	if current_weapon.type == Weapon.Type.KNIFE:
		print('>>> knife attack!!')
		return true

	current_weapon.bullets -= 1
	current_weapon.timer = 0

	bullet_direction = (endPoint.global_position - startPoint.global_position).normalized()
	var bullet = Bullet.instantiate()

	root.add_child(bullet)
	bullet.global_position = endPoint.global_position

	# FIXME: Rotation e direction têm offset entre si??
	bullet.rotation = PI/2 + bullet_direction.angle()
	bullet.direction = bullet_direction

	emit_signal('weapon_shot', current_weapon_i, current_weapon.bullets)
	return true

func reload() -> bool:
	if current_weapon.clips <= 0:
		return false

	if current_weapon.bullets == current_weapon.bullets_per_clip:
		return false

	current_weapon.bullets = current_weapon.bullets_per_clip
	current_weapon.clips -= 1

	emit_signal('weapon_reloaded', current_weapon_i, current_weapon.bullets, current_weapon.clips)
	return true

func change_weapon(target_weapon: String):
	var weapon_i = int(target_weapon) - 1
	if weapon_i == current_weapon_i:
		return
	current_weapon = weapons[weapon_i]
	current_weapon_i =  weapon_i as Weapon.Type

