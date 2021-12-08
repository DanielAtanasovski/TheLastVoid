extends Area2D
class_name Tile

onready var sprite : AnimatedSprite = $AnimatedSprite;
onready var unitSprite : Sprite = $Sprite
onready var lifeLabel : Label = $Sprite/InfoPanel/HBoxContainer/Life/HBoxContainer/LifeUI
onready var attackLabel : Label = $Sprite/InfoPanel/HBoxContainer/Attack/HBoxContainer/AttackUI
onready var infoPanel : Control = $Sprite/InfoPanel
onready var deathAnimation : AnimatedSprite = $DeathAnimation

# Moving
var spritePosition : Vector2
var moving : bool = false
var targetDistance: float = 0
var targetDirection : Vector2 = Vector2.ZERO
var target : Vector2 = Vector2.ZERO
var targetSpeed : float = 0
var timeElapsed : float = 0

var leftUnitInfoPos : Vector2 = Vector2(-58, -2)
var rightUnitInfoPos : Vector2 = Vector2(14, -2)
var belowUnitInfoPos : Vector2 = Vector2(-22, 12)

signal isClicked

func _ready() -> void:
	spritePosition = unitSprite.global_position
	
#func _process(delta: float) -> void:
#	if moving:
#		unitSprite.global_position += targetDirection * targetSpeed * delta
#		if unitSprite.global_position.distance_to(target) < targetSpeed * delta:
#			unitSprite.global_position = target
#			moving = false

func setUnitData(unit : UnitResource):
	unitSprite.texture = unit.sprite;
	lifeLabel.text = String(unit.health);
	attackLabel.text = String(unit.attack);

func faceLeft(value : bool):
	unitSprite.set_flip_h(value)
	if value:
		infoPanel.rect_position = rightUnitInfoPos
	else:
		infoPanel.rect_position = leftUnitInfoPos

func resetTile():
	unitSprite.texture = null;
	unitSprite.global_position = spritePosition
	unitSprite.visible = true
	lifeLabel.text = "";
	attackLabel.text = "";
	setVisible(false);
	setSelected(false);

func moveToX(_xValue : float, _withinTime : float, delta : float) -> bool:
	return moveToPoint(Vector2(_xValue, unitSprite.global_position.y), _withinTime, delta)

func moveToPoint(_position : Vector2, _withinTime : float, delta : float) -> bool:
	if timeElapsed > _withinTime:
		unitSprite.global_position = _position
		# Reached Destination
		moving = false
		timeElapsed = 0
		return true
	
	if moving:
		# Moving Towards Destination
		timeElapsed += delta
		unitSprite.global_position = unitSprite.global_position.move_toward(_position, targetSpeed * delta)
		return false
	
	# Calculate New Destination
	target = _position
	targetDistance = unitSprite.global_position.distance_to(target)
	targetDirection = (target - unitSprite.global_position).normalized()
	
	targetSpeed = targetDistance / _withinTime
#	global_position += targetDirection * targetSpeed
	moving = true
	
	return false

func moveToHome(_time : float, delta : float) -> bool:
	return moveToPoint(spritePosition, _time, delta)

func playDeathAnimation() -> bool:
	if deathAnimation.playing:
		if deathAnimation.frame == deathAnimation.frames.get_frame_count("default")-1:
			deathAnimation.stop()
			deathAnimation.visible = false
			deathAnimation.frame = 0
			return true
	else:
		deathAnimation.visible = true
		unitSprite.visible = false
		deathAnimation.play()
	return false

func setSelected(selected: bool):
	if selected:
		unitSprite.modulate = Color.gray;
	else:
		unitSprite.modulate = Color.white;
		
func setVisible(value : bool) -> void:
	infoPanel.visible = value

func getSpriteStartPosition() -> Vector2:
	return spritePosition

func _on_Tile_mouse_entered() -> void:
	sprite.frame = 1;
	if unitSprite.texture != null:
		setVisible(true)

func _on_Tile_mouse_exited() -> void:
	sprite.frame = 0;
	if unitSprite.texture != null:
		setVisible(false)

func _on_Tile_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		var mouseEvent := event as InputEventMouseButton
		if (mouseEvent.button_index == BUTTON_LEFT and mouseEvent.pressed == false):
			emit_signal("isClicked", get_index());
