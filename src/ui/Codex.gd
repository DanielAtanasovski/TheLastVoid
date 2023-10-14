extends Control

enum CodexState {
	Closed,
	Buttons,
	Units, 
	InUnit,
	Perks
}

var state : int = CodexState.Closed
@export var unitGuides : Array = [] # (Array, Resource)

@onready var infoPanel = $InfoPanel
@onready var buttonContainer = $InfoPanel/VBoxContainer/ButtonContainer
@onready var unitContainer = $InfoPanel/VBoxContainer/UnitContainer
@onready var perkContainer = $InfoPanel/VBoxContainer/PerkContainer

func setVisible(value : bool) -> void:
	infoPanel.visible = value

func _closeAllTabs() -> void:
	buttonContainer.visible = false
	unitContainer.visible = false
	perkContainer.visible = false

func _on_CodexButton_button_up() -> void:
	if state == CodexState.Closed:
		_closeAllTabs()
		infoPanel.visible = true
		buttonContainer.visible = true
		state = CodexState.Buttons

func _on_BackButton_button_up() -> void:
	if state == CodexState.Buttons:
		_closeAllTabs()
		infoPanel.visible = false
		state = CodexState.Closed
	elif state == CodexState.Units or state == CodexState.Perks:
		_closeAllTabs()
		buttonContainer.visible = true
		state = CodexState.Buttons

func _on_UnitsButton_button_up() -> void:
	_closeAllTabs()
	unitContainer.visible = true
	state = CodexState.Units

func _on_PerksButton_button_up() -> void:
	_closeAllTabs()
	perkContainer.visible = true
	state = CodexState.Perks
