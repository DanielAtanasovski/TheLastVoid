extends TextureRect

@onready var player : Player = $"/root/Player"

func _ready() -> void:
	player.connect("PlayerEnergyUpdate", Callable(self, "updateSprite"));
	updateSprite(player.energy);
	
func updateSprite(value : int) -> void:
	texture.region.position.y = value * 16;
