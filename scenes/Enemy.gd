extends KinematicBody2D

var gravity = 1000
var max_speed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var start_direction = Vector2.RIGHT

func _ready():
	direction = start_direction
	$GoalDetector.connect("area_entered", self, "goal_entered")
	$HitBoxArea.connect("area_entered", self, "hitbox_entered")


func _process(delta):
	"""
	Basic enemy movement.
	"""
	velocity.x = (direction * max_speed).x # we can use vectors to define direction 
	
	# apply gravity to the enemy
	if !is_on_floor():
		velocity.y += gravity * delta
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# flip animated sprite
	$AnimatedSprite.flip_h = true if direction.x > 0 else false


func hitbox_entered(_area2d):
	queue_free()


func goal_entered(_area2d):
	"""
	Flip enemy once it has reached its goal point.
	"""
	direction *= -1
