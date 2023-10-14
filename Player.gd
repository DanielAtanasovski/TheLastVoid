extends Node

var energy : int = 3

var gameRound : int = 0
var hp : int = 4

var maxUnitEggs : int = 5
var unitEggs : Array = [] # in the form of unit resources
var units : Array = [
	null, # in the form of unit resources
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

# Signals
signal PlayerEnergyUpdate

func setEnergy(energy : int) -> void:
	if energy > 10:
		energy = 10
	self.energy = energy;
	emit_signal("PlayerEnergyUpdate", self.energy);

func buyUnit(unit : UnitResource, cost : int) -> bool:
	if unitEggs.size() < maxUnitEggs:
		if energy >= cost:
			unitEggs.append(unit);
			setEnergy(energy - cost);
			return true
	return false

func removeUnitEgg(egg : UnitResource) -> void:
	for index in range(0, unitEggs.size()):
		var unit : UnitResource = unitEggs[index];
		if unit == egg:
			unitEggs.remove_at(index)
			return

func restart() -> void:
	units = [
	null, # in the form of unit resources
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	]
	hp = 4
	energy = 3
