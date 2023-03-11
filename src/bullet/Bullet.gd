extends Area2D

var speed := 1000
var direction := Vector2.RIGHT

func _process(delta: float) -> void:
	position += direction*speed*delta

func _on_timer_timeout() -> void:
	queue_free()
