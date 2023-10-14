extends Node2D

enum STATE {
	MENU,
	BASE,
	TRANSITION_TO_SHOP,
	SHOP,
	TRANSITION_TO_BASE,
	TRANSITION_TO_FIGHT,
	FIGHT,
}

var state : int = STATE.BASE;
var tutorial : bool = false;

var gameRound : int = 0

# References
@onready var startGameTimer : Timer = $Timers/StartGameTimer;
@onready var camera : Camera2D = $Camera2D

# Scenes
@onready var baseScene : BaseState = $Base
@onready var shopScene : Node2D = $Shop
@onready var fightScene : Node2D = $Fight

# Shop
var generatedShop : bool = false
var shopUnits : Array = []

# Fight
var calculateFight : bool = false
var fightActions : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startGameTimer.wait_time = 1;
	startGameTimer.start();
	shopScene.connect("GoToBase", Callable(self, "goToBase"));
	baseScene.connect("GoToShop", Callable(self, "goToShop"));
	baseScene.connect("GoToFight", Callable(self, "goToFight"));
#	fightScene.connect("GoToBase", self, "goToBase")
	fightScene.connect("FightOver", Callable(self, "endRound"))
	

func _process(delta: float) -> void:
	processState()

func processState() -> void:
	# Handle States
	match state:
		STATE.BASE:
			baseState()
		STATE.TRANSITION_TO_SHOP:
			transitionToShopState()
		STATE.SHOP:
			shopState()
		STATE.TRANSITION_TO_BASE:
			transitionToBaseState()
		STATE.TRANSITION_TO_FIGHT:
			transitionToFightState()
		STATE.FIGHT:
			fightState()

# States

func baseState() -> void:
	baseScene.setVisible(true);
	if Player.gameRound > 10:
		print("Survived 10 Rounds")

func transitionToShopState() -> void:
	camera.position = shopScene.position
	baseScene.setVisible(false);
	state = STATE.TRANSITION_TO_SHOP;
	
	if !generatedShop:
		shopScene.setupShop();
		generatedShop = true;
	if camera.get_screen_center_position().distance_to(shopScene.global_position) <= 2:
		state = STATE.SHOP;
		shopScene.setVisible(true)

func shopState() -> void:
	if Input.is_action_just_released("transitionToShop"):
		state = STATE.TRANSITION_TO_BASE;

func transitionToBaseState() -> void:
	camera.position = baseScene.position
	shopScene.setVisible(false)
	state = STATE.TRANSITION_TO_BASE
	if camera.get_screen_center_position().distance_to(baseScene.global_position) <= 2:
		state = STATE.BASE;
		baseScene.setVisible(true);
		baseScene.updateUnitEggs();
		
func transitionToFightState() -> void:
	camera.position = fightScene.position
	baseScene.setVisible(false)
	state = STATE.TRANSITION_TO_FIGHT
	
	if !calculateFight:
		fightActions = FightManager.calculateFight()
		calculateFight = true
	
	if camera.get_screen_center_position().distance_to(fightScene.global_position) <= 2:
		state = STATE.FIGHT
		fightScene.playReplay(fightActions)
		calculateFight = false

func fightState() -> void:
	pass

# Callbacks

func goToBase() -> void:
	transitionToBaseState();
	baseScene.updateGrid()

func goToShop() -> void:
	transitionToShopState();

func goToFight() -> void:
	transitionToFightState()

func endRound() -> void:
	# Determine Energy
	Player.gameRound += 1
	shopScene.setupShop()
	match fightActions["Winner"]:
		"PLAYER":
			Player.setEnergy(Player.energy + 2)
		"OPPONENT":
			Player.hp -= 1
		"DRAW":
			Player.setEnergy(Player.energy + 1)
	Player.setEnergy(Player.energy + 2)

	goToBase()

# Timers

func _on_StartGameTimer_timeout() -> void:
	#	state = STATE.TRANSITION_TO_SHOP
	pass
