extends Node2D

@onready var label = $Label
@onready var player = $Player

var text := ''
var diff := 0.0
var diff_deg := 0.0
var cos_diff := 0.0

func _process(_delta: float) -> void:
	text = ''
	text += 'mov       %+d°\n' % rad_to_deg(player.movement_input.angle())
	text += 'rot       %+d°\n' % round(rad_to_deg(player.rotation))
	text += '\n'
	
	diff = player.movement_input.angle() - player.rotation
	diff_deg = rad_to_deg(diff)
	cos_diff = cos(diff)
	
	text += 'diff      %.2f\n' % player.diff
	text += 'diff_deg  %+d°\n' % abs(diff_deg)
	text += 'cos_diff  %+0.1f\n' % cos_diff
	text += '%s' % player.animatedSpriteLegs.animation
	label.text = text
