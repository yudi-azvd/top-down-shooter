@tool
extends AnimatedSprite2D

var anims_dict = {
	HandgunIdle = Vector2(29, -12),
	HandgunShoot = Vector2(28, -12),
	HandgunMelee = Vector2(41, 3),
	HandgunMove = Vector2(27, -10),
	HandgunReload = Vector2(29, -5),

	RifleIdle = Vector2(62, -17),
	RifleMelee = Vector2(64, -25),
	RifleMove = Vector2(61, -17),
	RifleShoot = Vector2(61, -17),
	RifleReload = Vector2(60, -13),

	KnifeIdle = Vector2(30, 0),
	KnifeMove = Vector2(-28, 10),
	KnifeShoot = Vector2(60, 36),
}

func apply_offset(anim_name: StringName = &'') -> void:
	if anim_name not in anims_dict:
		push_error('Not recognized animation: ', anim_name)
	else:
		offset = anims_dict[anim_name]

func _on_animation_changed() -> void:
	apply_offset(animation)
