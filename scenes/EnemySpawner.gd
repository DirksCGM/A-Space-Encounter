extends Position2D

# define a user dropdown
enum Direction  {RIGHT, LEFT}

export (Direction) var start_direction
export (PackedScene) var enemy_scene # easy for developer

var current_enemy_node = null # keep track of the current enemy node
var spawn_on_next_tick = false


func _ready():
	$SpawnTimer.connect("timeout", self, "on_spawn_timer_timeout")
	call_deferred("spawn_enemy") # run when the scene is ready


func spawn_enemy():
	"""
	We get the parent node from the enemy scene and add
	spawner to all enemy nodes within the scene.
	"""
	current_enemy_node = enemy_scene.instance()
	current_enemy_node.start_direction = Vector2.RIGHT if start_direction == Direction.RIGHT else Vector2.LEFT
	get_parent().add_child(current_enemy_node) # replace all instances of enemy with enemy spawner
	
	# set enemy node instance to global position
	current_enemy_node.global_position = global_position


func check_enemy_spawn():
	"""
	Uses a timer to regularly check if the enemy has spawned.
	"""
	# a safe way to see if the object exists
	if !is_instance_valid(current_enemy_node):
		if spawn_on_next_tick:
			spawn_enemy()
			spawn_on_next_tick = false
		else:
			spawn_on_next_tick = true

func on_spawn_timer_timeout():
	check_enemy_spawn()
