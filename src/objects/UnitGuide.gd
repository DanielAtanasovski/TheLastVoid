extends Resource
class_name UnitGuide

export(int) var healthMin;
export(int) var healthMax;
export(int) var attackMin;
export(int) var attackMax;
export(Texture) var sprite;

func _init(healthMin = 0, healthMax = 1, attackMin = 0, attackMax = 1, sprite = null) -> void:
	self.healthMin = healthMin;
	self.healthMax = healthMax;
	self.attackMin = attackMin;
	self.attackMax = attackMax;
	self.sprite = sprite;
