extends Node

class WeaponSfx:
	var reload: AudioStreamMP3
	var shot: AudioStreamMP3

var _rifle_sfx = WeaponSfx.new()
var _handgun_sfx = WeaponSfx.new()
@onready var _sfx_shot: AudioStreamPlayer = $SfxShot
@onready var _sfx_reload: AudioStreamPlayer = $SfxReload

func _ready() -> void:
	_rifle_sfx.reload = preload('res://assets/sfx/rifle-reload.mp3')
	# FIXME: esse asset é temporário!
	_rifle_sfx.shot = preload('res://assets/sfx/handgun-shot.mp3')

	_handgun_sfx.reload = preload('res://assets/sfx/handgun-reload.mp3')
	_handgun_sfx.shot = preload('res://assets/sfx/handgun-shot.mp3')

	_sfx_shot.stream = _handgun_sfx.shot

## FIXME: Não é eficiente!
func play_shot():
	if _sfx_shot.playing:
		var new_gun_shot: AudioStreamPlayer = _sfx_shot.duplicate()
		get_parent().add_child(new_gun_shot)
		new_gun_shot.play()
		await new_gun_shot.finished
		new_gun_shot.queue_free()
	else:
		_sfx_shot.play()

func play_reload():
	_sfx_reload.play()

func change_weapon(weapon: Item.Type):
	match weapon:
		Item.Type.HANDGUN:
			_sfx_reload.stream = _handgun_sfx.reload
			_sfx_shot.stream = _handgun_sfx.shot
		Item.Type.RIFLE:
			_sfx_reload.stream = _rifle_sfx.reload
			_sfx_shot.stream = _rifle_sfx.shot
		_:
			push_error('Item not found: ', weapon)
