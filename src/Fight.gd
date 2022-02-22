extends Node2D

var actions : Dictionary
	# actions : {
	#	"PlayerGrid" : Array, (What the board looks like)
	#	"OpponentGrid" : Array, (What the board looks like)
	#	"ActionStack" : Array (fights, buffs and other actions performed in current cycle)
	# }

var currentClock : int = 0
var clockSpeed : int = 1
var actionSpeed : float = 2
var maxClocks : int = 1
var cycleActions : Array = [] # Of FightCycleResource
var actionStage : int = 0

var fightOver : bool = false

onready var timer : Timer = $ClockTimer
onready var actionTimer : Timer = $ActionTimer
onready var playerGrid : Node2D = $Tiles/PlayerGrid
onready var opponentGrid : Node2D = $Tiles/OpponentGrid
onready var fightX : Node2D = $FightX
onready var animationPlayer : AnimationPlayer = $CanvasLayer/Results/AnimationPlayer
onready var winnerLabel : Label = $CanvasLayer/Results/CenterContainer/Label

signal GoToBase
signal FightOver

## Datastructure to represent previous and current state of unit in the 
## current cycle
## E.g. Showing previous and next state resources for unit 1 (0) and unit 2 (1)
##
## var ActionDictionary : Dictionary = {
##	0: {
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

# TODO:
# 1. Animation Intro (Units moving towards Grid in Cycle 0 formation)
# Loop:
# 2. Reset Grind to formation set by cycle
# 2. Iterate through all action animations for current Cycle
# 3. Increase Cycle Count

func _process(delta: float) -> void:
	if cycleActions.size() > 0:
		_handleAction(delta)

func playReplay(_actions : Dictionary):
	actions = _actions
	maxClocks = actions["Clock"]
	currentClock = 0
	actionStage = 0
	resetGrids()
	timer.wait_time = clockSpeed
	timer.one_shot = true
	timer.start()

func resetGrids() -> void:
	# Player Grid
	for _tile in playerGrid.get_children():
		var tile : Tile = _tile
		tile.resetTile()
		if actions[currentClock]["PlayerGrid"][tile.get_index()] != null:
			tile.setUnitData(actions[currentClock]["PlayerGrid"][tile.get_index()])
		else:
			tile.resetTile()
	# Enemy Grid
	for _tile in opponentGrid.get_children():
		var tile : Tile = _tile
		tile.resetTile()
		tile.faceLeft(true)
		if actions[currentClock]["OpponentGrid"][tile.get_index()] != null:
			tile.setUnitData(actions[currentClock]["OpponentGrid"][tile.get_index()])

func _on_Timer_timeout() -> void:
#	var currentState : Dictionary = actions[currentClock]
	if (currentClock+1) > maxClocks:
		if actions["Winner"] == "PLAYER":
			winnerLabel.text = "Player Wins The Fight"
			animationPlayer.play("PlayerWins")
		elif actions["Winner"] == "OPPONENT":
			winnerLabel.text = "Player Lost The Fight"
			animationPlayer.play("PlayerLoses")
		else:
			winnerLabel.text = "Player Draws The Fight"
			animationPlayer.play("PlayerLoses")
		fightOver = true

	if currentClock > maxClocks:
		# TODO: Update Player Units
		currentClock = 0
		animationPlayer.stop(true)
		animationPlayer.play("RESET")
		Player.units = actions[maxClocks]["PlayerGrid"]
		emit_signal("FightOver")
		emit_signal("GoToBase")
	else:
		# Handle Action
		handleActions()
		currentClock += 1
		
func _onDoneLastCycleAction() -> void:
	resetGrids()
	if fightOver:
		timer.start(2.5)
		fightOver = false
	else:
		timer.start()
	
func handleActions() -> void:
	cycleActions = actions[currentClock]["ActionStack"]
	if cycleActions.size() <= 0:
		_onDoneLastCycleAction()

func _handleAction(delta : float) -> void:
	var currentAction : FightCycleResource = cycleActions[0]
	match currentAction.cycleType:
		
		FightCycleResource.CycleType.Attack:
			# Three Stages
			# 1. Move towards Centre
			# 2. Change Health
			# 3. Move Back
			var playerTile : Tile = playerGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
			var opponentTile : Tile = opponentGrid.get_child(currentAction.ActionDictionary[1]["Previous"]["Index"])
			
			if actionStage == 0:
				# Move
				playerTile.moveToX(fightX.global_position.x, actionSpeed / 3, delta)
				opponentTile.moveToX(fightX.global_position.x, actionSpeed / 3, delta)

				if !playerTile.moving and !opponentTile.moving:
					actionStage += 1

			elif actionStage == 1:
				# Change Health
				if actionTimer.time_left <= 0:
					actionTimer.start(actionSpeed / 3)
				
				# TODO: Effect when changing data (maybe colour)
				playerTile.setUnitData(currentAction.ActionDictionary[0]["Current"]["Resource"])
				opponentTile.setUnitData(currentAction.ActionDictionary[1]["Current"]["Resource"])
			else:
				playerTile.moveToHome(actionSpeed / 3, delta)
				opponentTile.moveToHome(actionSpeed / 3, delta)
				
				if !playerTile.moving and !opponentTile.moving:
					actionStage = 0
					cycleActions.pop_front()


		FightCycleResource.CycleType.Move:		
			if currentAction.ActionDictionary[0]["Player"]:
				# Move Player Unit
				var playerTile : Tile = playerGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
				var playerFutureTile : Tile = playerGrid.get_child(currentAction.ActionDictionary[0]["Current"]["Index"])
				var playerFuturePosition : Vector2 = playerFutureTile.getSpriteStartPosition()
				if playerTile.moveToPoint(playerFuturePosition, actionSpeed / 2, delta):
					playerTile.resetTile()
					playerFutureTile.setUnitData(currentAction.ActionDictionary[0]["Previous"]["Resource"])
					cycleActions.pop_front()

			else:
				# Move Opponent Unit
				var opponentTile : Tile = opponentGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
				var opponentFutureTile : Tile = opponentGrid.get_child(currentAction.ActionDictionary[0]["Current"]["Index"])
				var opponentFuturePosition : Vector2 = opponentFutureTile.getSpriteStartPosition()
				if opponentTile.moveToPoint(opponentFuturePosition, actionSpeed / 2, delta):
					opponentTile.resetTile()
					opponentFutureTile.setUnitData(currentAction.ActionDictionary[0]["Previous"]["Resource"])
					cycleActions.pop_front()

		FightCycleResource.CycleType.Death:
			if currentAction.ActionDictionary[0]["Player"]:
				var playerTile : Tile = playerGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
				if playerTile.playDeathAnimation():
					cycleActions.pop_front()
			else:
				var opponentTile : Tile = opponentGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
				if opponentTile.playDeathAnimation():
					cycleActions.pop_front()
			
		
		FightCycleResource.CycleType.Ability:
			match currentAction.abilityType:
				UnitResource.Abilities.SuperchargedRound:
					if currentAction.ActionDictionary[0]["Player"]:
						var playerTile : Tile = playerGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
						if playerTile.playAbilityAnimation(UnitResource.Abilities.SuperchargedRound, [opponentGrid.get_child(currentAction.ActionDictionary[3]["Previous"]["Index"]).position.x] , delta):
							cycleActions.pop_front()
					else:
						var opponentTile : Tile = opponentGrid.get_child(currentAction.ActionDictionary[0]["Previous"]["Index"])
						if opponentTile.playAbilityAnimation(UnitResource.Abilities.SuperchargedRound, [playerGrid.get_child(currentAction.ActionDictionary[1]["Previous"]["Index"]).position.x] , delta):
							cycleActions.pop_front()

			pass
	
	if cycleActions.size() <= 0:
		_onDoneLastCycleAction()

func _on_ActionTimer_timeout() -> void:
	actionStage += 1
