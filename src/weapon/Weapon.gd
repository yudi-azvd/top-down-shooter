class_name Weapon
extends Node

var cooldown: float = 1
var timer : float = 0.0
var bullets_per_magazine: int = 1
var bullets: int = bullets_per_magazine
var magazines: int = 1
var type: Type

enum Type {
	RIFLE,
	HANDGUN,
	KNIFE,
}
