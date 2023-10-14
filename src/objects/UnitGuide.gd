extends Resource
class_name UnitGuide

@export var healthMin: int;
@export var healthMax: int;
@export var attackMin: int;
@export var attackMax: int;
@export var sprite: Texture2D;

@export var appliedAbilitysEditor : Array = [] # (Array, UnitResource.Abilities)
@export var appliedAbilitysCooldownsEditor : Array = [] # (Array, int)

func _init(healthMin = 0, healthMax = 1, attackMin = 0, attackMax = 1, sprite = null) -> void:
	self.healthMin = healthMin;
	self.healthMax = healthMax;
	self.attackMin = attackMin;
	self.attackMax = attackMax;
	self.sprite = sprite;
