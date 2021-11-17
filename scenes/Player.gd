# Player
extends KinematicBody2D

var gravity = 1000
var velocity = Vector2(0, 0)
var max_hz_speed = 125
var hz_acceleration = 2000
var jump_speed = 360
var jump_termination_multiplier = 3

func _ready():
	pass


func _process(delta):
	"""
	A process that is applied every frame in the engine loop.
	Delta is num secs since last frame has passed. 
	"""
	var move_vector = get_movement_vector()
	
	# set player run speed
	# set acceleration for player run in velocity.x
	# every frame we have acceleration added at a constant rate, using delta to keep it smooth
	velocity.x += move_vector.x * hz_acceleration * delta
	
	# add a deceleration condition
	if move_vector.x == 0:
		# lerp() is good but will decellerate based on the frames, meaning
		# different frame-rates affect gameply, so math is needed to develop
		# a framerate independent lerp
		# so not: velocity.x = lerp(velocity.x, 0, .1)
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		
	
	# set the speed limit of the character
	velocity.x = clamp(velocity.x, - max_hz_speed, max_hz_speed)
	
	# determine jump mechanics
	# if jump nutton is pressed, allow jump and only if player is on the floor
	if move_vector.y < 0 && is_on_floor():
		velocity.y = move_vector.y * jump_speed
	
	
	# ###################
	# Environment Gravity
	# jump variablitly by manipulating gravity
	# this means if the player jumps, they can controll the strenght of
	# the jump based on how the jump key is pressed
	if velocity.y < 0 && !Input.is_action_pressed("jump"):
		velocity.y += gravity * jump_termination_multiplier * delta
	else:
		# increase y-velocity of player by the defined gravity 
		velocity.y += gravity * delta
	
	# move player based on defined player velocity
	# this method returns a velocity after collision processing that we can use 
	# we set velocity state to processing output to set velocity to 0 on collision
	# also set the up directon so the method can determine jump directon
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# ################
	# Player Animation
	update_anmiation()


func get_movement_vector():
	# Movement
	var move_vector = Vector2(0, 0)
	# set move vector on a scale of 0-1 for "strength" of input, can be used for analogue inputs
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# set player jump if button is pressed
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	
	return move_vector


func update_anmiation():
	"""
	Takes current movement state and velocity of the player
	and applies the relevant animations to the player sprite.
	"""
	var movement_vector = get_movement_vector()
	
	# is player not on ground
	if !is_on_floor():
		$AnimatedSprite.play("jump")
	# if player is running
	elif movement_vector.x != 0:
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	# flip sprite based on movement only when input is given
	if movement_vector.x != 0:
		$AnimatedSprite.flip_h = true if movement_vector.x > 0 else false
