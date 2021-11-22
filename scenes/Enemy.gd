extends KinematicBody2D

# define a user dropdown
enum Direction  {RIGHT, LEFT}
export (Direction) var start_direction

var gravity = 1000
var max_speed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO

func _ready():
	direction = Vector2.RIGHT if start_direction == Direction.RIGHT else Vector2.LEFT
	$GoalDetector.connect("area_entered", self, "goal_entered")

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


func goal_entered(_area2d):
	"""
	Flip enemy once it has reached its goal point.
	"""
	direction *= -1
