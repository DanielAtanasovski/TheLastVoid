extends Area2D
class_name UnitEgg

signal isLeftClicked
signal isRightClicked

var inShop : bool = false
var unit : UnitResource = null
var cost : int = 0
var selected : bool = false
var locked : bool = false

@onready var unitSprite : Sprite2D = $UnitSprite
@onready var selectSprite : Sprite2D = $SelectSprite
@onready var eggSprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var infoPanel : Panel = $InfoPanel
@onready var lifeUI : Label = $InfoPanel/VBoxContainer/HBoxContainer/Life/HBoxContainer/LifeUI
@onready var attackUI : Label = $InfoPanel/VBoxContainer/HBoxContainer/Attack/HBoxContainer/AttackUI
@onready var costSprite : AnimatedSprite2D = $CostSprite
@onready var lockSprite : AnimatedSprite2D = $Lock

func setCost(value : int) -> void:
	cost = value
	costSprite.frame = value;

func setSprite(sprite : Texture2D) -> void:
	unitSprite.texture = sprite;

func setInShop(value : bool):
	inShop = value;

func setSpriteVisible(value : bool):
	unitSprite.visible = value

func setCostVisible(value : bool):
	costSprite.visible = value;

func setEggMode(mode : bool):
	eggSprite.frame = 1 if mode else 0

func setSelected(selected : bool):
	if selected:
		eggSprite.modulate = Color.GRAY
	else:
		eggSprite.modulate = Color.WHITE

func toggleLock():
	locked = !locked
	if locked:
		eggSprite.modulate = Color.GOLD
		lockSprite.visible = true
	else:
		eggSprite.modulate = Color.WHITE
		lockSprite.visible = false

func _on_UnitEgg_mouse_entered() -> void:
	if unit == null:
		return
		
	lifeUI.text = str(unit.health);
	attackUI.text = str(unit.attack);
	infoPanel.visible = true;
	selectSprite.visible = true;

func _on_UnitEgg_mouse_exited() -> void:
	infoPanel.visible = false;
	selectSprite.visible = false;

func _on_UnitEgg_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		var mouseEvent := event as InputEventMouseButton
		if (mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.pressed == false):
			emit_signal("isLeftClicked", self)
		elif (mouseEvent.button_index == MOUSE_BUTTON_RIGHT and mouseEvent.pressed == false):
			emit_signal("isRightClicked", self)
