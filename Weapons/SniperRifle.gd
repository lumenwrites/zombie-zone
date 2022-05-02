extends "res://Weapons/Weapon.gd"

onready var camera_rig = get_node("/root/World/Player/CameraRig")
onready var raycast = $WeaponModel/RayCast
onready var laser = $WeaponModel/Laser
	
func _ready():
	parent.speed *= speed_modifier
	if not get_parent().get_parent() is Player: return # if bot has a laser rifle, dont change player's zoom.
	camera_rig.current_zoom = 15

func _exit_tree():
	parent.speed /= speed_modifier
	if not get_parent().get_parent() is Player: return
	camera_rig.current_zoom = camera_rig.default_zoom

func _physics_process(delta):
	if raycast.is_colliding():
		var dist = raycast.global_transform.origin.distance_to(raycast.get_collision_point())
		laser.scale.z = dist/500
