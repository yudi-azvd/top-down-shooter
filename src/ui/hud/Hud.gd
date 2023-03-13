extends CanvasLayer

@onready var rifleBullets = $Weapons/Box/Rifle/Info/Bullets
@onready var rifleClips = $Weapons/Box/Rifle/Info/Clips

@onready var handgunBullets = $Weapons/Box/Handgun/Info/Bullets
@onready var handgunClips = $Weapons/Box/Handgun/Info/Clips

var timer := 7.0
var text := ''

