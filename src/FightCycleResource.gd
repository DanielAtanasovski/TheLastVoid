extends Resource
class_name FightCycleResource

enum CycleType {
	Attack,
	Move,
	Death,
	Ability
}

var cycleType : int = 0
var abilityType : int = 0

## Datastructure to represent previous and current state of unit in the 
## current cycle
## E.g. Showing previous and next state resources for unit 1 (0) and unit 2 (1)
##
## var ActionDictionary : Dictionary = {
##	0 : {
##		"Previous": {
##			"Index" : -1,
##			"Resource" : null
##		},
##		"Current": {
##			"Index" : -1,
##			"Resource" : null
##		}
##		"Player": false
##	},
##
##	1: {
##		"Previous": {
##			"Index" : -1,
##			"Resource" : null
##		},
##		"Current": {
##			"Index" : -1,
##			"Resource" : null
##		}
##		"Player": false
##	}
##}
##
var ActionDictionary : Dictionary = {
	0 : { # Unit Index
		"Previous": {
			"Index" : -1, # Position on board
			"Resource" : null, # Unit Data
			"Player" : true # Owned by Player?
		},
		"Current": {
			"Index" : -1,
			"Resource" : null,
			"Player" : true
		}
	},
	
	1: {
		"Previous": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		},
		"Current": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		}
	},
	
	2: {
		"Previous": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		},
		"Current": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		}
	},
	
	3: {
		"Previous": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		},
		"Current": {
			"Index" : -1,
			"Resource" : null,
			"Player" : false
		}
	}
}
#var unitIndex1 : int = -1
#var unitResource1 : UnitResource = null
#
#var unitIndex2 : int = -1
#var unitResource2 : UnitResource = null

func _init(_cycleType : int = 0) -> void:
	cycleType = _cycleType
#	unitIndex1 = _unitIndex1
#	unitIndex1 = _unitIndex2
	
# Attack Action
## Setup Attack Action Information
func setupAttack(_unit1Index : int, _unit1Resource : UnitResource, _unit2Index : int, _unit2Resource : UnitResource) -> void:
	cycleType = CycleType.Attack
	# FIXME: Not necessarily optimised, can save some memory by not copying every resource
	# First Unit
	ActionDictionary[0]["Previous"]["Index"] = _unit1Index
	ActionDictionary[0]["Previous"]["Resource"] = _duplicateUnit(_unit1Resource)
	
	var currentResource : UnitResource = _duplicateUnit(_unit1Resource)
	currentResource.health -= _unit2Resource.attack
	ActionDictionary[0]["Current"]["Index"] = _unit1Index
	ActionDictionary[0]["Current"]["Resource"] = currentResource
	ActionDictionary[0]["Player"] = true
	
	# Second Unit
	ActionDictionary[1]["Previous"]["Index"] = _unit2Index
	ActionDictionary[1]["Previous"]["Resource"] = _duplicateUnit(_unit2Resource)
	
	currentResource = _duplicateUnit(_unit2Resource)
	currentResource.health -= _unit1Resource.attack
	ActionDictionary[1]["Current"]["Index"] = _unit2Index
	ActionDictionary[1]["Current"]["Resource"] = currentResource
	ActionDictionary[1]["Player"] = false

# TODO Change Input to dictionary
func setupAbility(_abilityType : int, _player : bool, _positionIndex : int, _unit : UnitResource, _dictionaryOfData : Dictionary) -> void:
	# First Unit is unit performing attack
	# Rest are units affected
	# Form: [index, unit, index, unit, etc...]
	
	# SuperCharged Bullet
	# NOTE: This is fixed to exactly 3 in enemy units lane,
	# This 'should' be expanded to be size independent and for varying
	# formations.
	cycleType = CycleType.Ability
	
	match _abilityType:
		# SuperCharged Round Ability
		UnitResource.Abilities.SuperchargedRound:
			abilityType = UnitResource.Abilities.SuperchargedRound
			ActionDictionary[0]["Previous"]["Index"] = _positionIndex
			ActionDictionary[0]["Previous"]["Resource"] = _duplicateUnit(_unit)
			ActionDictionary[0]["Current"]["Index"] = _positionIndex
			ActionDictionary[0]["Current"]["Resource"] = _duplicateUnit(_unit)
			ActionDictionary[0]["Player"] = _player
			var baseUnit : UnitResource = _unit
			var unit : UnitResource
			
			# First Enemy Unit 2,3
			ActionDictionary[1]["Previous"]["Index"] = _dictionaryOfData["ROWINDEXES"][0]
			ActionDictionary[1]["Previous"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][0])
			ActionDictionary[1]["Current"]["Index"] = _dictionaryOfData["ROWINDEXES"][0]
			ActionDictionary[1]["Current"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][0])
			
			# Second Enemy Unit 4,5
			ActionDictionary[2]["Previous"]["Index"] = _dictionaryOfData["ROWINDEXES"][1]
			ActionDictionary[2]["Previous"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][1])
			ActionDictionary[2]["Current"]["Index"] = _dictionaryOfData["ROWINDEXES"][1]
			ActionDictionary[2]["Current"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][1])
			
			# Third Enemy Unity 6,7
			ActionDictionary[3]["Previous"]["Index"] = _dictionaryOfData["ROWINDEXES"][2]
			ActionDictionary[3]["Previous"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][2])
			ActionDictionary[3]["Current"]["Index"] = _dictionaryOfData["ROWINDEXES"][2]
			ActionDictionary[3]["Current"]["Resource"] = _duplicateUnit(_dictionaryOfData["ROW"][2])
			
			# Apply Damage
			if ActionDictionary[3]["Current"]["Resource"] != null:
				ActionDictionary[3]["Current"]["Resource"].health -= floor(baseUnit.attack / 2)
			if ActionDictionary[2]["Current"]["Resource"] != null:
				ActionDictionary[2]["Current"]["Resource"].health -= floor(baseUnit.attack / 2)
			if ActionDictionary[1]["Current"]["Resource"] != null:
				ActionDictionary[1]["Current"]["Resource"].health -= floor(baseUnit.attack / 2)
			


func setupDeath(_unitIndex : int, player : bool) -> void:
	cycleType = CycleType.Death
	ActionDictionary[0]["Player"] = player
	ActionDictionary[0]["Previous"]["Index"] = _unitIndex

# Move Action
## Setup Move Action Information
func setupMove(_previousUnitIndex : int, _currentUnitIndex : int, _unit : UnitResource, player : bool) -> void:
	cycleType = CycleType.Move
	var unit : UnitResource = _duplicateUnit(_unit)
	ActionDictionary[0]["Previous"]["Index"] = _previousUnitIndex
	ActionDictionary[0]["Previous"]["Resource"] = unit
	ActionDictionary[0]["Current"]["Index"] = _currentUnitIndex
	ActionDictionary[0]["Current"]["Resource"] = unit
	ActionDictionary[0]["Player"] = player


func _duplicateUnit(_unit : UnitResource) -> UnitResource:
	if _unit == null:
		return null
	return UnitResource.new(_unit.health, _unit.attack, _unit.sprite)


func _superchargedAttack() -> void:
	pass
