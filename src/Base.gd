extends Node2D
class_name BaseState


@onready var UI : Control = $CanvasLayer/BaseUI
@onready var grid : Node2D = $Grid
@onready var eggs : Node2D = $Units
@onready var base : AnimatedSprite2D = $BaseAnimatedSprite
@onready var roundLabel : Label = $CanvasLayer/BaseUI/RoundLabel
@onready var roundLabel2 : Label = $CanvasLayer/EndGame/CenterContainer/VBoxContainer/roundLabel2
@onready var endGameScreen : ColorRect = $CanvasLayer/EndGame

var selectedEgg : UnitEgg = null
var selectedUnit : Tile = null

signal GoToShop
signal GoToFight

func _ready() -> void:
	for x in grid.get_children():
		var tile : Tile = x as Tile;
		tile.connect("isClicked", Callable(self, "onTileClicked"))
	for x in eggs.get_children():
		var egg : UnitEgg = x as UnitEgg;
		egg.connect("isLeftClicked", Callable(self, "onEggClicked"));
	_updateHealth()

func setVisible(visible : bool):
	UI.visible = visible;
	
func _on_ShopButton_button_up() -> void:
	emit_signal("GoToShop")
	
func updateUnitEggs() -> void:
	clearUnitEggs()
	for index in range(Player.unitEggs.size()):
		var unitEgg : UnitEgg = eggs.get_child(index);
		unitEgg.visible = true;
		unitEgg.setSpriteVisible(true);
		unitEgg.setEggMode(true);
		unitEgg.unit = Player.unitEggs[index];
		unitEgg.setSprite(Player.unitEggs[index].sprite);

func updateGrid() -> void:
	_updateHealth()
	_clearGrid()
	for index in range(0, Player.units.size()):
		var unit : UnitResource = Player.units[index]
		
		if unit == null:
			continue
		
		var tile : Tile = grid.get_child(index)
		tile.setUnitData(unit)
		tile.setVisible(false)

func _updateHealth() -> void:
	match Player.hp:
		4:
			base.animation = "Level3"
		3:
			base.animation = "Level2"
		2:
			base.animation = "Level1"
		1:
			base.animation = "Level0"
	roundLabel.text = "Round: " + str(Player.gameRound)
	roundLabel2.text = "You Survived " + str(Player.gameRound) + " Rounds!"
	
	if Player.hp <= 0:
		endGameScreen.visible = true

func _clearGrid() -> void:
	for _tile in grid.get_children():
		var tile : Tile = _tile
		tile.resetTile()

func clearUnitEggs() -> void:
	for index in range(0, eggs.get_child_count()):
		var unitEgg : UnitEgg = eggs.get_child(index);
		unitEgg.setSpriteVisible(false);
		unitEgg.setEggMode(false);
		unitEgg.unit = null;
		unitEgg.setSprite(null);
		unitEgg.setSelected(false);

func onTileClicked(index : int) -> void:
	if selectedEgg:
		# Spawn Egg
		if Player.units[index] == null:
			var tile : Tile = grid.get_child(index);
			tile.setUnitData(selectedEgg.unit);
#			tile.setVisible(true)
			Player.units[index] = selectedEgg.unit;
			Player.removeUnitEgg(selectedEgg.unit);
			selectedEgg = null;
			updateUnitEggs();
		else:
			# Deselect Current Egg
			selectedEgg.setSelected(false)
			selectedEgg = null
	else:
		if selectedUnit:
			# Deselect Current Unit
			if selectedUnit.get_index() == index:
				selectedUnit.setSelected(false)
				selectedUnit = null
			else:
				# Swap Units Positions
				var tempUnit : UnitResource = Player.units[selectedUnit.get_index()];
				Player.units[selectedUnit.get_index()] = Player.units[index]
				Player.units[index] = tempUnit;
				selectedUnit.setSelected(false)
				selectedUnit = null
				updateGrid()
		else:
			# Select unit in grid
			selectedUnit = grid.get_child(index)
			selectedUnit.setSelected(true)
	
func onEggClicked(egg : UnitEgg) -> void:
	if egg.unit == null:
		return
	
	if selectedUnit:
		selectedUnit.setSelected(false)
		selectedUnit = null;
		return
	
	if selectedEgg != null:
		selectedEgg.setSelected(false);
		if selectedEgg == egg:
			selectedEgg = null
			return
	selectedEgg = egg;
	selectedEgg.setSelected(true);

func _on_StartRoundButton_button_up() -> void:
	emit_signal("GoToFight")
