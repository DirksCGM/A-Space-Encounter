# Player
extends KinematicBody2D

signal died

enum State {NORMAL, DASHING}

export(int, LAYERS_2D_PHYSICS) var dash_hazard_mask

var gravity = 1000
var velocity = Vector2(0, 0)
var max_hz_speed = 125
var max_dash_speed = 500
var min_dash_speed = 200
var hz_acceleration = 2000
var jump_speed = 330
var jump_termination_multiplier = 3
var has_double_jump = false
var has_dash = false
var current_state = State.NORMAL
var is_state_new = true

var default_hazard_mask = 0


func _ready():
	# Hurt player on hazard area entered
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")
	default_hazard_mask = $HazardArea.collision_mask


func _process(delta):
	"""
	A process that is applied every frame in the engine loop.
	Delta is num secs since last frame has passed. 
	"""
	# switch statement for the player dash/normal state
	match current_state:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dashing(delta)
	
	is_state_new = false


func change_state(new_state):
	"""
	Handles the state change for player normal and dashing mechanic.
	"""
	current_state = new_state
	is_state_new = true


func process_normal(delta):
	"""
	Normal player movement processing
	"""
	# disable dash for killing enemies
	if is_state_new:
		$DashArea/CollisionShape2D.disabled = true
		$HazardArea.collision_mask = default_hazard_mask
	
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
	# also allow jump during coyote timer period, along with double jump
	if move_vector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || has_double_jump):
		velocity.y = move_vector.y * jump_speed
		
		# double jump off when busy jumping an double jump was used
		if !is_on_floor() && $CoyoteTimer.is_stopped():
			has_double_jump = false
		
		$CoyoteTimer.stop()
	
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

	"""
	*CoyoteTimer*
	This is a time period after a plaer falls off of a platform
	where they are technically not touching the ground where the
	player can still execute a jump.
	This is used to handle the jarring experience of the inability
	to jump when one falls of a platform, making the game experience
	a lot smoother for the player.
	ie. if a player runs of a platform, they have a split second where
	they can still jump.
	"""
	var was_on_floor = is_on_floor()
	# move player based on defined player velocity
	# this method returns a velocity after collision processing that we can use 
	# we set velocity state to processing output to set velocity to 0 on collision
	# also set the up directon so the method can determine jump directon
	velocity = move_and_slide(velocity, Vector2.UP)

	# run coyote timer at appropriate time
	if was_on_floor && !is_on_floor():
		$CoyoteTimer.start()

	# double jump functionality
	if is_on_floor():
		has_double_jump = true
		has_dash = true

	# dash if dash button is pressed
	if has_dash and Input.is_action_just_pressed("dash"):
		call_deferred("change_state", State.DASHING)
		has_dash = false
		
	update_anmiation()


func process_dashing(delta):
	"""
	Dashing player movement processing
	"""
	# only set velocity on first frame and decay dash
	if is_state_new:
		$DashArea/CollisionShape2D.disabled = false # enable dash for killing enemies
		$AnimatedSprite.play("jump")
		$HazardArea.collision_mask = dash_hazard_mask
		var velocity_mod = 1
		var move_vector = get_movement_vector()
		
		# dash in the current direction of the player
		if velocity.x != 0:
			velocity_mod = sign(move_vector.x)
		else:
			velocity_mod = 1 if $AnimatedSprite.flip_h else -1
			
		velocity = Vector2(max_dash_speed * velocity_mod, 0)

	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))
	
	if abs(velocity.x) < min_dash_speed:
		call_deferred("change_state", State.NORMAL)


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


func on_hazard_area_entered(area2d):
	"""
	When the player enteres a hazard area, they must emit a die signal
	that will makr them as dead.
	"""
	emit_signal("died")
