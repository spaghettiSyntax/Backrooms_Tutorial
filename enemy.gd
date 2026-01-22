extends CharacterBody3D


const SPEED = 4.0
const JUMPSCARE_DISTANCE = 1.5
const AGGRO_DISTANCE = 20


# Glitch Settings
@export var min_glitch_interval: float = 0.5 # Minimum seconds between glitches
@export var max_glitch_interval: float = 1.5 # Maximum seconds between glitches


var glitch_timer: float = 0.0
var next_glitch_interval: float = 1.0
var safe_position: Vector3


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var player = get_tree().get_first_node_in_group("Player")


func _ready():
	# Save spawn as first safe spot
	safe_position = global_position
	
	# Set the first random timer
	next_glitch_interval = randf_range(min_glitch_interval, max_glitch_interval)
	
	
func _physics_process(delta: float) -> void:
	if not player: return
	
	# Ensure mesh is visible if it wasn't toggled back
	if not mesh_instance_3d.visible:
		mesh_instance_3d.visible = true
		
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < AGGRO_DISTANCE:
		# Chase logic
		
		# Move towards player
		nav_agent.target_position = player.global_position
		var next_location = nav_agent.get_next_path_position()
		var current_location = global_position
		var new_velocity = (next_location - current_location).normalized() * SPEED
		
		velocity = new_velocity
		
		# Glitch Timer
		glitch_timer += delta
		if glitch_timer >= next_glitch_interval:
			_perform_glitch()
			
			# Reset Timer
			glitch_timer = 0.0
			
			# New Random Time
			next_glitch_interval = randf_range(min_glitch_interval, max_glitch_interval)
	else:
		# Idle
		velocity = Vector3.ZERO
		
	move_and_slide()
	
	if dist_to_player < JUMPSCARE_DISTANCE:
		_jumpscare()
		
		
func _perform_glitch():
	# Visual flicker
	mesh_instance_3d.visible = false
	
	# Rubberband Teleport
	# SAVE the current valid spot as the NEXT safe spot
	var current_spot = global_position
	
	# Teleport back to the OLD safe spot
	global_position = safe_position
	
	# Update the safe sport for next time!
	safe_position = current_spot
	
	# Audio static
	var random_pitch = randf_range(0.8, 1.2)
	audio_player.pitch_scale = random_pitch
	audio_player.play()
	
	
func _jumpscare():
	print("YOU DIED")
	set_physics_process(false)
	
	if player:
		player.set_physics_process(false)
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
