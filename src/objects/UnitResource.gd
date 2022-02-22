extends Resource
class_name UnitResource

enum Effects {
	
}

# Structure of ability dictionary
enum AbilityStructures {
	AppliedAbilities, # Array : Abilities assigned to units
	AppliedAbilitiesMaxCooldowns, # Array : Max cooldown of abilities
	AppliedAbilitiesCurrentCooldowns # Array : Current cooldown of abilities
}

# Abilities specific to units
enum Abilities {
	SuperchargedRound, # Attacks all units in enemy row
	ArtilleryRound # Apply damage to first enemy in row every turn
}

var health;
var attack;
var sprite;

var alwaysAttack = false

var appliedAbilitys : Array = []
var appliedAbilitysCooldowns : Array = []

var abilityDictionary : Dictionary = {
	AbilityStructures.AppliedAbilities : [],
	AbilityStructures.AppliedAbilitiesMaxCooldowns : [],
	AbilityStructures.AppliedAbilitiesCurrentCooldowns : []
}

# Constructor
func _init(_health = 0, _attack = 0, _sprite = null, _abilities = [], _abilitiesCooldowns = []) -> void:
	self.health = _health;
	self.attack = _attack;
	self.sprite = _sprite;
	self.abilityDictionary[AbilityStructures.AppliedAbilities] = _abilities
	self.abilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns] = _abilitiesCooldowns
	self.abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns] = self.abilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns]

# Return all abilties associated with this unit
func getAbilities() -> Array:
	return abilityDictionary[AbilityStructures.AppliedAbilities]

# Reset ability cooldown to max cooldown
func solveAbility(_ability : int) -> void:
	for index in range(0, abilityDictionary[AbilityStructures.AppliedAbilities].size()):
		if abilityDictionary[AbilityStructures.AppliedAbilities][index] == _ability:
			abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] = abilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns][index]
			return

# Process all abilities cooldowns
func decrementAbilityCooldowns() -> void:
	for index in range(0, abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].size()):
		abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] -= 1
		if abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] < 0:	
			abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] = 0

# Return all abilities that are no longer on cooldown
func getReadyAbilities() -> Array:
	var readyAbilities = []

	for index in range(0, abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].size()):
		if abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns][index] <= 0:
			readyAbilities.append(abilityDictionary[AbilityStructures.AppliedAbilities][index])

	return readyAbilities

# Return boolean on whether given ability is associated with this unit
func hasAbility(_ability : int) -> bool:
	for x in abilityDictionary[AbilityStructures.AppliedAbilities]:
		if x == _ability:
			return true
	return false

# Return boolean on whether this unit has any abilities
func hasAnyAbility() -> bool:
	if Abilities.size() > 0:
		return true
	return false

# Add ability to this unit with given max cooldown
func addAbility(_ability : int, _cooldown : int) -> void:
	abilityDictionary[AbilityStructures.AppliedAbilities].append(_ability)
	abilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns].append(_cooldown)
	abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].append(_cooldown)

# Remove given ability from this unit
func removeAbility(_ability : int) -> void:
	var found : int = abilityDictionary[AbilityStructures.AppliedAbilities].find(_ability)
	if found != -1:
		abilityDictionary[AbilityStructures.AppliedAbilities].remove(found)
		abilityDictionary[AbilityStructures.AppliedAbilitiesMaxCooldowns].remove(found)
		abilityDictionary[AbilityStructures.AppliedAbilitiesCurrentCooldowns].remove(found)

func mergeUnits(unit : UnitResource) -> void:
	# TODO: Decide how to merge Abilitys
	pass
	
