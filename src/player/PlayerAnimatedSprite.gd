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
}

# Talvez não seja necessaŕio o pplay. é só conectar ao sinal do animation ou usar apenas o _set mesmo
func pplay(_name: StringName = &"", _custom_speed: float = 1.0, _from_end: bool = false) -> void:
	if _name == animation:
		return

	super.play(_name, _custom_speed, _from_end)
	apply_offset(_name)


func _set(property: StringName, value) -> bool:
	# FIXME: Se atirar muito rápido, não volta pra animação de Idle
	if property == 'animation':
		animation = value
		print('animação -> ', animation)
		apply_offset(value)
		return true
	return false

func apply_offset(anim_name: StringName = &'') -> void:
	if anim_name not in anims_dict:
		push_error('Not recognized animation: ', anim_name)
	else:
		offset = anims_dict[anim_name]

