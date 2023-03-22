extends CanvasLayer

@onready var rifleBullets = $Weapons/Box/Rifle/Info/Bullets
@onready var rifleMagazines = $Weapons/Box/Rifle/Info/Magazines

@onready var handgunBullets = $Weapons/Box/Handgun/Info/Bullets
@onready var handgunMagazines = $Weapons/Box/Handgun/Info/Magazines

@onready var weaponManager = $'/root/World/Player/WeaponManager'

var timer := 7.0
var text := ''

func _ready() -> void:
	weaponManager.weapon_shot.connect(_on_weapon_shot)
	weaponManager.weapon_reloaded.connect(_on_weapon_reloaded)

	handgunBullets.text = str(weaponManager.handgun.bullets)
	handgunMagazines.text = str(weaponManager.handgun.magazines)
	rifleBullets.text = str(weaponManager.rifle.bullets)
	rifleMagazines.text = str(weaponManager.rifle.magazines)

func _on_weapon_shot(weapon, remaining_bullets: int):
	var bullets = str(remaining_bullets)

	if weapon == Weapon.Type.HANDGUN:
		handgunBullets.text = bullets
	elif weapon == Weapon.Type.RIFLE:
		rifleBullets.text = bullets
	else:
		print_debug('Weapon not recognized: ', weapon)

func _on_weapon_reloaded(weapon, bullets: int, magazines: int):
	var b = str(bullets)
	var c = str(magazines)

	if weapon == Weapon.Type.HANDGUN:
		handgunBullets.text = b
		handgunMagazines.text = c
	elif weapon == Weapon.Type.RIFLE:
		rifleBullets.text = b
		rifleMagazines.text = c
	else:
		print_debug('Weapon not recognized: ', weapon)
