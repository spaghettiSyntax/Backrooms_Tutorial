extends StaticBody3D


@export var prompt_message = "Collect Tape"


func interact():
	# Find the Player and update the count
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		player.collect_tape()
	
	# Visual of the tape
	visible = false
	
	# Play a sound here later
	
	queue_free()
