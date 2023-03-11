extends Node2D

@onready var endPoint = $EndPoint
@onready var startPoint = $StartPoint
@onready var root := get_tree().get_root()

var Bullet = preload('res://src/weapon/Bullet.tscn')

var bullet_direction := Vector2.ZERO

@export_range(0.1, 2.0) var handgun_cooldown := 0.1481
var handgun_timer := 0.0
var handgun_bullets := 12
var handgun_clips := 4
var handgun_bullets_per_clip := 12

func _process(delta: float) -> void:
	handgun_timer += delta

func shoot() -> bool:
	if handgun_timer < handgun_cooldown:
		return false

	if handgun_bullets <= 0:
		return false

	handgun_bullets -= 1
	handgun_timer = 0
	bullet_direction = (endPoint.global_position - startPoint.global_position).normalized()
	var bullet = Bullet.instantiate()

	root.add_child(bullet)
	bullet.global_position = endPoint.global_position

	# FIXME: Rotation e direction têm offset entre si??
	bullet.rotation = PI/2 + bullet_direction.angle()
	bullet.direction = bullet_direction

	return true

func reload() -> bool:
	if handgun_clips <= 0:
		return false

	handgun_bullets = handgun_bullets_per_clip
	handgun_clips -= 1
	return true
