extends CanvasLayer

@onready var rifleBullets = $Weapons/Box/Rifle/Info/Bullets
@onready var rifleMagazines = $Weapons/Box/Rifle/Info/Magazines

@onready var handgunBullets = $Weapons/Box/Handgun/Info/Bullets
@onready var handgunMagazines = $Weapons/Box/Handgun/Info/Magazines

@onready var itemManager = $'/root/World/Player/ItemManager'

var timer := 7.0
var text := ''

func _ready() -> void:
	itemManager.weapon_shot.connect(_on_weapon_shot)
	itemManager.weapon_reloaded.connect(_on_weapon_reloaded)

	handgunBullets.text = str(itemManager.handgun.bullets)
	handgunMagazines.text = str(itemManager.handgun.magazines)
	rifleBullets.text = str(itemManager.rifle.bullets)
	rifleMagazines.text = str(itemManager.rifle.magazines)

func _on_weapon_shot(weapon, remaining_bullets: int):
	var bullets = str(remaining_bullets)

	if weapon == Item.Type.HANDGUN:
		handgunBullets.text = bullets
	elif weapon == Item.Type.RIFLE:
		rifleBullets.text = bullets
	else:
		print_debug('Item not recognized: ', weapon)

func _on_weapon_reloaded(weapon, bullets: int, magazines: int):
	var b = str(bullets)
	var c = str(magazines)

	if weapon == Item.Type.HANDGUN:
		handgunBullets.text = b
		handgunMagazines.text = c
	elif weapon == Item.Type.RIFLE:
		rifleBullets.text = b
		rifleMagazines.text = c
	else:
		print_debug('Item not recognized: ', weapon)
