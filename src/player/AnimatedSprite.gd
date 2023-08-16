@tool
extends AnimatedSprite2D

var anims_dict = {
	HandgunIdle            = Vector2(29, -12),
	HandgunPrimaryAction   = Vector2(28, -12),
	HandgunSecondaryAction = Vector2(41, 3),
	HandgunMove            = Vector2(27, -10),
	HandgunReload          = Vector2(29, -5),

	RifleIdle            = Vector2(62, -17),
	RifleSecondaryAction = Vector2(64, -25),
	RifleMove            = Vector2(61, -17),
	RiflePrimaryAction   = Vector2(61, -17),
	RifleReload          = Vector2(60, -13),

	KnifeIdle          = Vector2(32, -3),
	KnifeMove          = Vector2(27, -5),
	KnifePrimaryAction = Vector2(55, 34),
}

func apply_offset(anim_name: StringName = &'') -> void:
	if anim_name not in anims_dict:
		push_error('Not recognized animation: ', anim_name)
	else:
		offset = anims_dict[anim_name]

func _on_animation_changed() -> void:
	apply_offset(animation)
