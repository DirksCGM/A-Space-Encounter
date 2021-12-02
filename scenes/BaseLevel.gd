extends Node

"""
We assume that the player is not resposible for the game mechanics, and 
is merely a vehicle of expereince within the game world. 
So the level scens that sit above all the mechanics are the ones that manage
player spawn location, death, last known location and so on.
"""

signal coin_total_change

var player_scene = preload("res://scenes/Player.tscn") # gets players scene in memory
var spawn_position = Vector2.ZERO
var current_player_node = null # keep player node in memory
var total_coins = 0
var collected_coins = 0

func _ready():
	spawn_position = $Player.global_position # start player where they were configured
	register_player($Player)
	coin_total_change(get_tree().get_nodes_in_group("coin").size()) # get total coin nodes in group
	
func coin_collected():
	"""
	Simple coin counter for the player.
	"""
	collected_coins += 1
	emit_signal("coin_total_change", total_coins, collected_coins)

func coin_total_change(new_total):
	"""
	Simple coin updater for the player.
	"""
	total_coins = new_total
	emit_signal("coin_total_change", total_coins, collected_coins)

func register_player(player):
	"""
	Listen to players death and add signal connection.
	"""
	current_player_node = player
	current_player_node.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)
	
func create_player():
	"""
	Creates the scene for the player.
	"""
	var player_instance = player_scene.instance()
	
	# below node is used beacuse it would otherwise be added to the bottom
	# of the scene tree and draw on-top of everything, making them incompatible
	# with the scene
	add_child_below_node(current_player_node, player_instance) # add player to the scene
	player_instance.global_position = spawn_position
	register_player(player_instance)

func on_player_died():
	"""
	Event on players death called as the player is registered.
	"""
	current_player_node.queue_free()
	create_player()
	
