extends Control


# References
onready var energyTexture : TextureRect = $CenterContainer/EnergyTexture
onready var player : Node = $"/root/Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("PlayerEnergyUpdate", self, "onPlayerEnergyUpdate");


func onPlayerEnergyUpdate(energy : int) -> void:
	var atlasTexture : AtlasTexture = energyTexture.texture;
	atlasTexture.region.position.y = energy * 16;
	energyTexture.texture = atlasTexture;
