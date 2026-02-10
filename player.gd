const MOUSE_SENSITIVITY = 0.003
const BOB_FREQ = 2.0
const BOB_AMP = 0.08



@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay



var t_bob = 0.0



func _ready():
@@ -91,6 +94,18 @@ func _physics_process(delta: float) -> void:
		camera_3d.transform.origin = camera_3d.transform.origin.lerp(Vector3.ZERO, 10 * delta)

	move_and_slide()














func _headbob(time) -> Vector3:
@@ -103,3 +118,18 @@ func _headbob(time) -> Vector3:
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP

	return pos
