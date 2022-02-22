extends Node

var unitGuides : Array = [
	preload("res://src/objects/Tank.tres")
]

enum Row {
	Top,
	Middle,
	Bottom
}

var currentCycle : int = 0

# Units
var opponentUnits : Array = [
	null, # in the form of unit resources
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null
	]
var playerUnitsCopy : Array

var fightCreation : Dictionary = {
	# Cycle : {
	#	"PlayerGrid" : Array, (What the board looks like)
	#	"OpponentGrid" : Array, (What the board looks like)
	#	"ActionStack" : Array (fights, buffs and other actions performed in current cycle)
	# }
}

var actions : Array = []
var nextPlayerGrid : Array = []
var nextOpponentGrid : Array = []

# Converts index to opponent equivalent
var orderMap : Dictionary = {
	0 : 2,
	1 : 1,
	2 : 0,
	3 : 5,
	4 : 4,
	5 : 3,
	6 : 8,
	7 : 7,
	8 : 6
}

######

func _ready() -> void:
	pass

# Returns an Array of randomly generated units
func generateUnits() -> Array:
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
	
	for index in _getRandomIndexes():
		units[index] = getRandomUnit()
		
	return units

# Generates an Array of random index values from 0-8
func _getRandomIndexes() -> Array:
	var indexes : Array = [0, 1, 2, 3, 4, 5, 6, 7, 8]
	var retIndexes : Array = []
	indexes.shuffle()
	
	var maxIndexes = Player.gameRound
	maxIndexes = int(clamp(maxIndexes, 1, 9))
	if maxIndexes >= 9:
		maxIndexes = 9
		indexes.shuffle()
		return indexes
		
	var count = 0
	indexes.shuffle()
	while count < maxIndexes:
		retIndexes.append(indexes[0])
		indexes.pop_front()
		count += 1
	
	return retIndexes

# Returns a random generated unit within the UnitGuides provided
func getRandomUnit() -> UnitResource:
	var rng = RandomNumberGenerator.new()

	var index : int = randi() % unitGuides.size()
	var randomHealth : int = rng.randi_range(unitGuides[index].healthMin, unitGuides[index].healthMax)
	var randomAttack : int = rng.randi_range(unitGuides[index].attackMin, unitGuides[index].attackMax)
	return UnitResource.new(randomHealth, randomAttack, unitGuides[index].sprite)

# Return Stack of Fight Events
func calculateFight() -> Dictionary:
	opponentUnits = generateUnits()
	currentCycle = 0
#	playerUnitsCopy = Player.units.duplicate(true)
	
	print(Player.units)
	nextPlayerGrid = deepCopyGrid(Player.units)
	nextOpponentGrid = deepCopyGrid(opponentUnits)
	
	while hasUnits(nextPlayerGrid) and hasUnits(nextOpponentGrid):
		# Reset
		fightCreation[currentCycle] = {
			"PlayerGrid" : [],
			"OpponentGrid" : [],
			"ActionStack" : [] # List of FightCycleResources
		}
		actions = []
		
		fightCreation[currentCycle]["PlayerGrid"] = deepCopyGrid(nextPlayerGrid)
		fightCreation[currentCycle]["OpponentGrid"] = deepCopyGrid(nextOpponentGrid)
		
		condenseFight()
		fightLoop()
		fightCreation[currentCycle]["ActionStack"] = actions
		
		currentCycle += 1
		if currentCycle > 90:
			pass
	
	# Final Cleanup
	# Reset
	fightCreation[currentCycle] = {
		"PlayerGrid" : [],
		"OpponentGrid" : [],
		"ActionStack" : [] # List of FightCycleResources
	}
	actions = []
	
	healthCheck()
	fightCreation[currentCycle]["PlayerGrid"] = deepCopyGrid(nextPlayerGrid)
	fightCreation[currentCycle]["OpponentGrid"] = deepCopyGrid(nextOpponentGrid)
	fightCreation[currentCycle]["ActionStack"] = actions
	
	# Determine Winner
	if  !hasUnits(nextPlayerGrid) and !hasUnits(nextOpponentGrid):
		fightCreation["Winner"] = "DRAW"
	else:
		fightCreation["Winner"] = "PLAYER" if hasUnits(nextPlayerGrid) else "OPPONENT"
		
	fightCreation["Clock"] = currentCycle
	return fightCreation

# Move units towards center if available
# TODO: Only if no enemy units in same row
func condenseFight() -> void:
	healthCheck()	
	# Positioning Check
	# Player
	# Top Row
	for index in range(0, 3):
		if nextPlayerGrid[index] != null:
			if nextPlayerGrid[index + 3] == null:
				# Move Positions
				nextPlayerGrid[index + 3] = nextPlayerGrid[index]
				nextPlayerGrid[index] = null
				# Submit Action
				var fightCycle : FightCycleResource = FightCycleResource.new()
				fightCycle.setupMove(index, index+3, nextPlayerGrid[index + 3], true)
				actions.append(fightCycle)
	# Bottom Row
	for index in range(6, 9):
		if nextPlayerGrid[index] != null:
			if nextPlayerGrid[index - 3] == null:
				# Move Positions
				nextPlayerGrid[index - 3] = nextPlayerGrid[index]
				nextPlayerGrid[index] = null
				# Submit Action
				var fightCycle : FightCycleResource = FightCycleResource.new()
				fightCycle.setupMove(index, index-3, nextPlayerGrid[index - 3], true)
				actions.append(fightCycle)
				
	# Opponent
	# Top Row
	for index in range(0, 3):
		if nextOpponentGrid[index] != null:
			if nextOpponentGrid[index + 3] == null:
				# Move Positions
				nextOpponentGrid[index + 3] = nextOpponentGrid[index]
				nextOpponentGrid[index] = null
				# Submit Action
				var fightCycle : FightCycleResource = FightCycleResource.new()
				fightCycle.setupMove(index, index+3, nextOpponentGrid[index + 3], false)
				actions.append(fightCycle)
	# Bottom Row
	for index in range(6, 9):
		if nextOpponentGrid[index] != null:
			if nextOpponentGrid[index - 3] == null:
				# Move Positions
				nextOpponentGrid[index - 3] = nextOpponentGrid[index]
				nextOpponentGrid[index] = null
				# Submit Action
				var fightCycle : FightCycleResource = FightCycleResource.new()
				fightCycle.setupMove(index, index-3, nextOpponentGrid[index - 3], false)
				actions.append(fightCycle)

# Check health of all units
func healthCheck() -> void:
	# Health Check
	# Player
	var removal : Array = []
	for index in range(0, nextPlayerGrid.size()):
		
		if nextPlayerGrid[index] == null:
			continue
		
		if nextPlayerGrid[index].health <= 0:
			removal.append(index)
	
	for del in removal:
		var fightCycle : FightCycleResource = FightCycleResource.new()
		fightCycle.setupDeath(del, true)
		actions.append(fightCycle)
		nextPlayerGrid[del] = null
	
	# Opponent
	removal = []
	for index in range(0, nextOpponentGrid.size()):
		if nextOpponentGrid[index] == null:
			continue
		
		if nextOpponentGrid[index].health <= 0:
			removal.append(index)
	
	for del in removal:
		var fightCycle : FightCycleResource = FightCycleResource.new()
		fightCycle.setupDeath(del, false)
		actions.append(fightCycle)
		nextOpponentGrid[del] = null
		
# Loop through rows and initiate fight with frontlines
func fightLoop() -> void:
	for index in range(0, 3):
		fightLoopRow(index)
	fightCreation[currentCycle]["ActionStack"] = actions

func fightLoopRow(row : int) -> void:
	var minValue : int = row * 3
	var maxValue : int = (row + 1) * 3
	var unit : UnitResource = null
	# Loop through all Unit Rows
	for index in range(minValue, maxValue):
		if nextPlayerGrid[index] != null:
			# Perform Perk / Unit Action
			unit = nextPlayerGrid[index]
			if unit.hasAnyAbility():
				resolveAbilities(unit, index, false)
				unit.decrementAbilityCooldowns()
		if nextOpponentGrid[orderMap[index]] != null:
			# Perform Perk / Unit Action
			unit = nextOpponentGrid[orderMap[index]]
			if unit.hasAnyAbility():
				resolveAbilities(unit, index, true)
				unit.decrementAbilityCooldowns()
	
	# Final condense as abilities might kill
	condenseFight()
	# Calculate fight result if any in row
	var fightCycle : FightCycleResource = calculateRowFight(row)
	if fightCycle != null:
		actions.append(fightCycle)

# Resolves all abilities of given unit that are no longer in cooldown
func resolveAbilities(unit : UnitResource, positionIndex : int, opponent : bool) -> void:
	print(unit.getAbilities())
	for ability in unit.getReadyAbilities():
		match ability:
			unit.Abilities.SuperchargedRound:
				print("SUPER ROUND")
				# Check if opponent is in the row
				if !_isUnitsInRow(_getRowIndex(positionIndex), !opponent):
					continue
					
				var oppositeRow : Array = _getRow(positionIndex, !opponent)
				var fightCycle : FightCycleResource = FightCycleResource.new()
				var dictionary : Dictionary = {
					"ROW" : oppositeRow,
					"ROWINDEXES": _getRowIndexes(_getRowIndex(positionIndex))
				}
				fightCycle.setupAbility(unit.Abilities.SuperchargedRound, !opponent, positionIndex, unit, dictionary)
				unit.solveAbility(unit.Abilities.SuperchargedRound)
				actions.append(fightCycle)
				
				# TODO: APPLITIES NOT APPLYING ???!!!
				if opponent:
					nextPlayerGrid[dictionary["ROWINDEXES"][0]] = fightCycle.ActionDictionary[1]["Current"]["Resource"]
					nextPlayerGrid[dictionary["ROWINDEXES"][1]] = fightCycle.ActionDictionary[2]["Current"]["Resource"]
					nextPlayerGrid[dictionary["ROWINDEXES"][2]] = fightCycle.ActionDictionary[3]["Current"]["Resource"]
				else:
					nextOpponentGrid[dictionary["ROWINDEXES"][0]] = fightCycle.ActionDictionary[1]["Current"]["Resource"]
					nextOpponentGrid[dictionary["ROWINDEXES"][1]] = fightCycle.ActionDictionary[2]["Current"]["Resource"]
					nextOpponentGrid[dictionary["ROWINDEXES"][2]] = fightCycle.ActionDictionary[3]["Current"]["Resource"]
				
			unit.Abilities.ArtilleryRound:
				pass
	pass

func _isUnitsInRow(row : int, opponent : bool) -> bool:
	for i in range(row * 3, (row + 1) * 3):
		if opponent:
			if nextOpponentGrid[i] != null:
				return true
		else:
			if nextPlayerGrid[i] != null:
				return true
	return false

func _getUnitsInRow(row : int, opponent : bool) -> Array:
	var rowUnits : Array = []
	for i in range(row * 3, (row + 1) * 3):
		if opponent:
			rowUnits.append(nextOpponentGrid[i])
		else:
			rowUnits.append(nextPlayerGrid[i])
	return rowUnits

# Returns an array of units in the given row and whether it is the opponent side
func _getRow(index : int, opponent : bool) -> Array:
	if index < 3:
		return _getUnitsInRow(Row.Top, opponent)
	elif index > 2 and index < 6:
		return _getUnitsInRow(Row.Middle, opponent)
	else:
		return _getUnitsInRow(Row.Bottom, opponent)

# Returns the row number of the given index position
func _getRowIndex(index : int) -> int:
	if index < 3:
		return Row.Top
	elif index > 2 and index < 6:
		return Row.Middle
	else:
		return Row.Bottom

# Returns list of indexes of a given row and whether it is the opponent side
func _getRowIndexes(row : int) -> Array:
	match row:
		Row.Top:
			return [0, 1, 2]
		Row.Middle:
			return [3, 4, 5]
		Row.Bottom:
			return [6, 7, 8]
	return [null, null, null]

func calculateRowFight(row : int) -> FightCycleResource:
	var minValue : int = row * 3
	var maxValue : int = (row + 1) * 3
	var fightCycle : FightCycleResource = FightCycleResource.new()
	var resolution : Array = [null,null,null,null]
	
	for cellIndex in range(minValue, maxValue):
		# Player
		if nextPlayerGrid[cellIndex] != null:
			if isFrontLine(cellIndex, false):
				resolution[0] = cellIndex
				resolution[1] = nextPlayerGrid[cellIndex]
		# Opponent
		if nextOpponentGrid[cellIndex] != null:
			if isFrontLine(cellIndex, true):
				resolution[2] = cellIndex
				resolution[3] = nextOpponentGrid[cellIndex]
	
	for x in resolution:
		if x == null:
			return null
	
	# Setup Action Event
	fightCycle.setupAttack(resolution[0], resolution[1], resolution[2], resolution[3])
		
	# Apply Damage
	nextPlayerGrid[resolution[0]] = fightCycle.ActionDictionary[0]["Current"]["Resource"]
	nextOpponentGrid[resolution[2]] = fightCycle.ActionDictionary[1]["Current"]["Resource"]  

	return fightCycle

func isFrontLine(position : int, opponent : bool) -> bool:
	# Initial frontline Check
	if opponent:
		# Opponent Grid
		if position == 0 or position == 3 or position == 6:
			return true
		if position == 1 or position == 4 or position == 7:
			if nextOpponentGrid[position-1] != null:
				return false
			else: return true
		if position == 2 or position == 5 or position == 8:
			if nextOpponentGrid[position-1] != null or nextOpponentGrid[position-2] != null:
				return false
			else: return true
	else:
		# Player Grid
		if position == 2 or position == 5 or position == 8:
			return true
		if position == 1 or position == 4 or position == 7:
			if nextPlayerGrid[position+1] != null:
				return false
			else: return true
		if position == 0 or position == 3 or position == 6:
			if nextPlayerGrid[position+1] != null or nextPlayerGrid[position+2] != null:
				return false
			else: return true

	# There is a unit in front	
	return false

# PreBuffs and 'Start of Battle' Actions
func initFightLoop() -> void:
	pass

func hasUnits(units: Array) -> bool:
	for unit in units:
		if unit != null:
			return true
	return false

func resolvePerks() -> void:
	pass
	
# Utility
func deepCopyGrid(grid : Array) -> Array:
	var retArray : Array = []
	retArray.resize(grid.size())
	for index in range(0, grid.size()):
		if grid[index] == null:
			retArray[index] = null
		else:
			retArray[index] = UnitResource.new(grid[index].health,
				grid[index].attack, grid[index].sprite)
			retArray[index].abilityDictionary = grid[index].abilityDictionary
	
	return retArray
