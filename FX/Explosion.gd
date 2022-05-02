extends Spatial

onready var camera = get_node("/root/World/Player/CameraRig")
onready var player = get_node("/root/World/Player")

func _ready():
#	$Fire.emitting = false
#	$SmokeCloud.emitting = false
#	$Debree.emitting = false
#	$SmokeRing.emitting = false
	$Fire.one_shot = true
	$SmokeCloud.one_shot = true
	$Debree.one_shot = true
	$SmokeRing.one_shot = true
	$ExplosionAudio.play()
	$AnimationPlayer.play("explode")
	global_transform.origin.y = 0.312 # drop it onto the ground
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	dist = clamp(dist,0,10)
	camera.shake_strength = range_lerp(dist, 10, 0, 0, 1)
	yield(get_tree().create_timer(5.0), "timeout")
	queue_free()

func explode():
	show()
	print("Explode")
	$Fire.emitting = true
	$SmokeCloud.emitting = true
	$Debree.emitting = true
	$SmokeRing.emitting = true
	$AnimationPlayer.play("explode")

