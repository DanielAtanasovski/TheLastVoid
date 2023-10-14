extends Node2D

@export var unitGuides : Array # (Array, Resource)
@export var tier2Cost: int
@export var tier3Cost: int
@export var refreshCost: int
signal GoToBase;

@onready var UI : Control = $CanvasLayer/UI
@onready var tier2BarAnimation : AnimationPlayer = $Tiers/Tier1/AnimatedSprite2D/AnimationPlayer2;
@onready var tier3BarAnimation : AnimationPlayer = $Tiers/Tier2/AnimatedSprite2/AnimationPlayer;
@onready var tier2Button : Button = $CanvasLayer/UI/Tier2;
@onready var tier3Button : Button = $CanvasLayer/UI/Tier3;
@onready var tier2Texture : TextureRect = $CanvasLayer/UI/Tier2Cost;
#onready var tier3Texture : TextureRect = $CanvasLayer/UI/Tier3Cost;

@onready var refreshButton : Button = $CanvasLayer/UI/MarginContainer/CenterContainer2/RefreshButton

# Tiers
@onready var tier1 : Node2D = $Units/Tier1
@onready var tier2 : Node2D = $Units/Tier2
@onready var tier3 : Node2D = $Units/Tier3

func _process(delta: float) -> void:
	if (Player.energy < tier2Cost):
		tier2Button.disabled = true;
	else:
		tier2Button.disabled = false
	if (Player.energy < tier3Cost):
		tier3Button.disabled = true;
	else:
		tier3Button.disabled = false;
		
	if (Player.energy < refreshCost):
		refreshButton.disabled = true
	else:
		refreshButton.disabled = false
	

func setupShop() -> void:
#	resetShop()
	setupTier(tier1, 1)

func resetShop() -> void:
	tier3Button.visible = true;
#	tier3Texture.visible = true;
#	tier3BarAnimation.stop()
	tier3BarAnimation.play("BoughtTier")
	tier3BarAnimation.seek(0, true)
	tier3BarAnimation.stop(true)
	tier2Button.visible = true;
	tier2Texture.visible = true;
	tier2BarAnimation.play("BoughtTier")
	tier2BarAnimation.seek(0, true)
	tier2BarAnimation.stop(true)

func _generateShop(amount : int) -> Array:
	var returnUnits : Array;
	
	for x in range(amount):
		returnUnits.append(generateRandomUnit());
	
	return returnUnits

func generateRandomUnit() -> UnitResource:
	var randomIndex = randi() % unitGuides.size();
	var randomUnitGuide : UnitGuide = unitGuides[randomIndex];
	
	# Create Unit
	var randomHealth = (randi() % randomUnitGuide.healthMax) + randomUnitGuide.healthMin;
	var randomAttack = (randi() % randomUnitGuide.attackMax) + randomUnitGuide.attackMin;
	
	print(randomUnitGuide.appliedAbilitysEditor)
	
	return UnitResource.new(randomHealth, randomAttack, randomUnitGuide.sprite, randomUnitGuide.appliedAbilitysEditor, randomUnitGuide.appliedAbilitysCooldownsEditor)

func _on_Tier3_button_up() -> void:
	Player.setEnergy(Player.energy - tier3Cost);
	setupTier(tier3, 2);
	tier3Button.visible = false;
#	tier3Texture.visible = false;
	tier3BarAnimation.play("BoughtTier");

func _on_Tier2_button_up() -> void:
	Player.setEnergy(Player.energy - tier2Cost);
	setupTier(tier2, 2);
	tier2Button.visible = false;
	tier2Texture.visible = false;
	tier2BarAnimation.play("BoughtTier");

func setVisible(visible : bool):
	UI.visible = visible

func setupTier(tier : Node2D, cost : int) -> void:
	var units : Array = _generateShop(tier.get_child_count())
	for x in range(0, tier.get_child_count()):
		var unit : UnitResource = units[x]
		var child : UnitEgg = tier.get_child(x)
		
		if child.locked:
			continue
		
		child.visible = true
		child.setSpriteVisible(true)
		child.setEggMode(true)
		child.setCostVisible(true)
		child.setCost(cost);
		child.unit = unit
		child.setSprite(unit.sprite)
		child.connect("isLeftClicked", Callable(self, "onLeftClickUnitEgg"));
		child.connect("isRightClicked", Callable(self, "onRightClickUnitEgg"))

func onLeftClickUnitEgg(egg : UnitEgg) -> void:
	if (Player.buyUnit(egg.unit, egg.cost)):
		if egg.locked:
			egg.toggleLock()
		egg.visible = false

func onRightClickUnitEgg(egg: UnitEgg) -> void:
	egg.toggleLock()

func _on_Button_button_up() -> void:
	emit_signal("GoToBase");

func _on_RefreshButton_button_up() -> void:
	setupShop()
	Player.setEnergy(Player.energy - refreshCost)
