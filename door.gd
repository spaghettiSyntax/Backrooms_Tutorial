extends Node3D


@onready var hinge: Node3D = get_parent()


var is_open = false


func interact():
	var tween = create_tween()
	if is_open:
		# Close the door
		tween.tween_property(hinge, "rotation:y", 0.0, 0.5)
	else:
		# Open the door (90 degrees)
		tween.tween_property(hinge, "rotation:y", deg_to_rad(90), 0.5)
		
	is_open = not is_open
