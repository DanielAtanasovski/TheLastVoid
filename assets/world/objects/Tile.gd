extends Area2D
class_name Tile

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D;
@onready var unitSprite : Sprite2D = $Sprite2D
@onready var lifeLabel : Label = $Sprite2D/InfoPanel/HBoxContainer/Life/HBoxContainer/LifeUI
@onready var attackLabel : Label = $Sprite2D/InfoPanel/HBoxContainer/Attack/HBoxContainer/AttackUI
@onready var infoPanel : Control = $Sprite2D/InfoPanel
@onready var deathAnimation : AnimatedSprite2D = $DeathAnimation

# Moving
var spritePosition : Vector2
var moving : bool = false
var targetDistance: float = 0
var targetDirection : Vector2 = Vector2.ZERO
var target : Vector2 = Vector2.ZERO
var targetSpeed : float = 0
var timeElapsed : float = 0

var animStarted : bool = false
var bulletScene : PackedScene = preload("res://src/scenes/bullet.tscn")
var bullet : Bullet = null
var facingLeft : bool = false

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
	lifeLabel.text = str(unit.health);
	attackLabel.text = str(unit.attack);

func faceLeft(value : bool):
	facingLeft = value
	unitSprite.set_flip_h(value)
	if value:
		infoPanel.position = rightUnitInfoPos
	else:
		infoPanel.position = leftUnitInfoPos

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

# Returns true on done
func playDeathAnimation() -> bool:
	if deathAnimation.is_playing():
		if deathAnimation.frame == deathAnimation.sprite_frames.get_frame_count("default")-1:
			deathAnimation.stop()
			deathAnimation.visible = false
			deathAnimation.frame = 0
			return true
	else:
		deathAnimation.visible = true
		unitSprite.visible = false
		deathAnimation.play()
	return false

# Returns true on done
func playAbilityAnimation(_perk : int, _data : Array, delta : float) -> bool:
	match _perk: 
		UnitResource.Abilities.SuperchargedRound:
			return _playSuperchargedRoundAnimation(_data[0])
	return false

# Return bool of if done animation
func _playSuperchargedRoundAnimation(_endX : int) -> bool:
	if animStarted:
		if abs(bullet.position.x - _endX) < 10:
			animStarted = false
			bullet.setDir(facingLeft)
			bullet.queue_free()
			return true
		return false
	else:
		bullet = bulletScene.instantiate()
		add_child(bullet)
		animStarted = true
		return false


func setSelected(selected: bool):
	if selected:
		unitSprite.modulate = Color.GRAY;
	else:
		unitSprite.modulate = Color.WHITE;
		
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
		if (mouseEvent.button_index == MOUSE_BUTTON_LEFT and mouseEvent.is_pressed() == false):
			emit_signal("isClicked", get_index());
