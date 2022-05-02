extends Spatial

const CRATE = preload("res://Pickups/Crate.tscn")

export var active = true
export var spawn_frequency = 20.0
export var level_size = 32
export var drop_height = 15

var can_spawn = false

func _ready():
	if active:
		yield(get_tree().create_timer(spawn_frequency), "timeout")
		can_spawn = true

func _physics_process(delta):
	if active and can_spawn:
		spawn()
		can_spawn = false
		yield(get_tree().create_timer(spawn_frequency), "timeout")
		can_spawn = true


func spawn():
	var instance = CRATE.instance()
	randomize()
	var spawn_pos = global_transform.origin
	var random_pos = Vector3(
		rand_range(spawn_pos.x-level_size/2,spawn_pos.x+level_size/2), 
		drop_height, 
		rand_range(spawn_pos.z-level_size/2,spawn_pos.z+level_size/2)
	)
	instance.global_transform.origin = random_pos
	instance.rotation_degrees = Vector3(rand_range(-360,360),rand_range(-360,360),rand_range(-360,360))
	# Set ammo weapon according to the number of crystals collected
	get_node("/root/World/Pickups").add_child(instance)
