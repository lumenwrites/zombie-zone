extends Position3D


export var default_zoom = 5
onready var current_zoom = default_zoom # changed by sniper rifle
onready var player = get_parent()

onready var camera = $Camera

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	follow_player()

	camera.translation.z = lerp(camera.translation.z, current_zoom, 2*delta)

func follow_player():
	var player_pos = player.global_transform.origin
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
	global_transform.origin.y = lerp(global_transform.origin.y, player_pos.y, 0.01)

