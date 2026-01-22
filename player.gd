extends CharacterBody3D


const SPEED = 3.0
const MOUSE_SENSITIVITY = 0.003
const BOB_FREQ = 2.0
const BOB_AMP = 0.08


@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay


var t_bob = 0.0


func _ready():
	# Hide the cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Mouse Look (Only works if captured)
	if event is InputEventMouseMotion \
		and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Rotate the whole body left/right (Y axis)
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			
			# Rotate just the head up/down (X Axis)
			head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			
			# Clamp head rotation
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Unlock the Mouse
	if event.is_action_pressed("quit"):
		# Make the mouse visible again
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	# Re-Lock the Mouse (Click to capture)
	# If the mouse is visible and we click the left mouse button, capture it again
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode  = Input.MOUSE_MODE_CAPTURED
				# We consume the event so we don't accidentally interact/shoot
				# the moment we click to focus
				get_viewport().set_input_as_handled()
				
	# Flashlight Toggle
	if event.is_action_pressed("toggle_flashlight"):
		flashlight.visible = not flashlight.visible
		#TODO: Add click sound here later
		
	# Interaction
	if event.is_action_pressed("interact"):
		if interaction_ray.get_collider():
			var collider = interaction_ray.get_collider()
			
			# "Duck Typing" - If it quacks like a duck, it's a duck.
			# If the object has an "interact" function, call it!
			if collider.has_method("interact"):
				collider.interact()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()	
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity.length() > 0 and is_on_floor():
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera_3d.transform.origin = _headbob(t_bob)
	else:
		# Reset camera smoothly when stopped
		camera_3d.transform.origin = camera_3d.transform.origin.lerp(Vector3.ZERO, 10 * delta)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	
	# Sine wave for vertical movement
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	
	# Cosine wave for horizontal movement (creates a figure-8 sway)
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos
