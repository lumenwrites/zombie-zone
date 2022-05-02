extends Position3D

export var target_rotation = deg2rad(-45)
export var default_zoom = 10
onready var current_zoom = default_zoom # changed by sniper rifle
onready var player = get_parent()

onready var camera = $Camera

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	follow_player()
	rotate_camera()
	camera.translation.z = lerp(camera.translation.z, current_zoom, 2*delta)
	

	shake_strength = lerp(shake_strength, 0, 0.1)
	shake()

export var max_offset = Vector2(0.1, 0.2)  # Maximum hor/ver shake in pixels.
export var max_roll = 3  # Maximum rotation in radians (use sparingly).
var shake_strength = 0.0

func shake():
	randomize()
	camera.rotation_degrees = Vector3()
	camera.translation.x = 0
	camera.translation.y = 0
	camera.rotation_degrees.z = max_roll * shake_strength * rand_range(-1, 1)
	camera.translation.x = max_offset.x * shake_strength * rand_range(-1, 1)
	camera.translation.y = max_offset.y * shake_strength * rand_range(-1, 1)


func follow_player():
	var player_pos = player.global_transform.origin
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
	global_transform.origin.y = lerp(global_transform.origin.y, player_pos.y, 0.01)

func rotate_camera():
	rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
	if Input.is_action_just_pressed("rotate_camera_cw"):
		target_rotation -= deg2rad(45)
	if Input.is_action_just_pressed("rotate_camera_ccw"):
		target_rotation += deg2rad(45)
