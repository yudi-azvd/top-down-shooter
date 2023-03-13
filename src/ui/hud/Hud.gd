extends CanvasLayer

@onready var rifleBullets = $Weapons/Box/Rifle/Info/Bullets
@onready var rifleClips = $Weapons/Box/Rifle/Info/Clips

@onready var handgunBullets = $Weapons/Box/Handgun/Info/Bullets
@onready var handgunClips = $Weapons/Box/Handgun/Info/Clips

@onready var weaponManager = $'/root/World/Player/WeaponManager'

var timer := 7.0
var text := ''

func _ready() -> void:
	weaponManager.weapon_shot.connect(_on_weapon_shot)
	weaponManager.weapon_reloaded.connect(_on_weapon_reloaded)

	handgunBullets.text = str(weaponManager.handgun.bullets)
	handgunClips.text = str(weaponManager.handgun.clips)
	rifleBullets.text = str(weaponManager.rifle.bullets)
	rifleClips.text = str(weaponManager.rifle.clips)

func _on_weapon_shot(weapon, remaining_bullets: int):
	var bullets = str(remaining_bullets)

	if weapon == weaponManager.Weapon.Type.HANDGUN:
		handgunBullets.text = bullets
	elif weapon == weaponManager.Weapon.Type.RIFLE:
		rifleBullets.text = bullets
	else:
		print_debug('Weapon not recognized: ', weapon)

func _on_weapon_reloaded(weapon, bullets: int, clips: int):
	var b = str(bullets)
	var c = str(clips)

	if weapon == weaponManager.Weapon.Type.HANDGUN:
		handgunBullets.text = b
		handgunClips.text = c
	elif weapon == weaponManager.Weapon.Type.RIFLE:
		rifleBullets.text = b
		rifleClips.text = c
	else:
		print_debug('Weapon not recognized: ', weapon)
