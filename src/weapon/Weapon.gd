class_name Weapon
extends Node

var cooldown: float = 1
var timer : float = 0.0
var bullets_per_magazine: int = 1
var bullets: int = bullets_per_magazine
var magazines: int = 1
var type: Type

var is_primary_action_continuous: bool = false
var is_secondary_action_continuous: bool = false

enum Type {
	RIFLE,
	HANDGUN,
	KNIFE,
}
