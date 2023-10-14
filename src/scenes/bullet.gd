extends Sprite2D
class_name Bullet

@export var velocity: int;

var dir : int = 1;

func _process(delta: float) -> void:
	position.x += velocity * dir * delta

func setDir(_dir : int) -> void:
	dir = _dir
