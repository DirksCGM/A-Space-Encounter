extends Camera2D

"""
We add a little bit of lerp movement to the camera to give it a more
smooth "human" movement when tracing the players movements.
"""

var target_position = Vector2.ZERO # keeps last known player position

# set editor variable for background color
export(Color, RGB) var background_color

func _ready():
	VisualServer.set_default_clear_color(background_color)

func _process(delta):
	get_target_position()
	
	# set global position based on lerp vector
	# looking for playrs last known postion and moving at a steady rate
	# from the players global position
	global_position = lerp(target_position, global_position, pow(2, -15 * delta))
	

func get_target_position():
	"""
	Set the cameras global position to the global position of the player.
	We monitor the Player Scene with the use of a "group" assigned to
	the Player node.
	"""
	# get all players of a group called "player"
	var players = get_tree().get_nodes_in_group("player")
	
	# only check global position if the player exists
	if players.size() > 0:
		print("player found, camera resetting")
		var player = players[0]
		target_position = player.global_position
