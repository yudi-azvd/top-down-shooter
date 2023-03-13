extends CanvasLayer

@onready var rifleBullets = $Weapons/Box/Rifle/Info/Bullets
@onready var rifleClips = $Weapons/Box/Rifle/Info/Clips

@onready var handgunBullets = $Weapons/Box/Handgun/Info/Bullets
@onready var handgunClips = $Weapons/Box/Handgun/Info/Clips

var timer := 7.0
var text := ''

func _process(delta: float) -> void:
	timer += delta
	var timer_as_int = int(timer + 1)
	text = '%2d' % timer_as_int
	rifleBullets.text = text
	handgunBullets.text = text
