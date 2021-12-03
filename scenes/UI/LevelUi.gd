extends CanvasLayer

func _ready():
	var base_level = get_tree().get_nodes_in_group("base_level")
	
	if base_level.size() > 0:
		base_level[0].connect("coin_total_change", self, "on_coin_total_change")


func on_coin_total_change(total_coins, collected_coins):
	$MarginContainer/HBoxContainer/CoinLabel.text = str(collected_coins, "/", total_coins)
