extends Resource
class_name UnitResource

enum Effects {
	
}

enum AbilityStructures {
	AppliedAbilities,
	AppliedAbilitiesMaxCooldowns,
	AppliedAbilitiesCurrentCooldowns
}

enum Abilities {
	SuperchargedRound,
	ArtilleryRound
}

export(int) var health;
export(int) var attack;
export(Texture) var sprite;

export(bool) var alwaysAttack = false

export(Array, Abilities) var appliedAbilitysEditor : Array = []
export(Array, Abilities) var appliedAbilitysCooldownsEditor : Array = []

var AbilityDictionary : Dictionary = {
	AbilityStructures.AppliedAbilities : [],
	AbilityStructures.AppliedAbilitiesMaxCooldowns : [],
	AbilityStructures.AppliedAbilitiesCurrentCooldowns : []
}

func _init(_health = 0, _attack = 0, _sprite = null) -> void:
	self.health = _health;
	self.attack = _attack;
	self.sprite = _sprite;

func getReadyAbilities() -> Array:
	var readyAbilities = []
	# Decrement	
	for index in range(0, AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].size()):
		AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] -= 1
		if AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] < 0:
			# Apply Ability		
			readyAbilities.append(AbilityDictionary[AbilityStructures.AppliedAbilities][index])
			AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] = AbilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns][index]
	return readyAbilities

func hasAbility(_ability : int) -> bool:
	for x in AbilityDictionary[AbilityStructures.AppliedAbilities]:
		if x == _ability:
			return true
	return false

func hasAnyAbility() -> bool:
	for x in AbilityDictionary[AbilityStructures.AppliedAbilities]:
			return true
	return false

func addAbility(_ability : int, _cooldown : int) -> void:
	AbilityDictionary[AbilityStructures.AppliedAbilities].append(_ability)
	AbilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns].append(_cooldown)
	AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].append(_cooldown)

func removeAbility(_ability : int) -> void:
	var found : int = AbilityDictionary[AbilityStructures.AppliedAbilities].find(_ability)
	if found != -1:
		AbilityDictionary[AbilityStructures.AppliedAbilities].remove(found)
		AbilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns].remove(found)
		AbilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].remove(found)

func mergeUnits(unit : UnitResource) -> void:
	# TODO: Decide how to merge Abilitys
	pass
	
