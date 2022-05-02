extends Spatial


const BULLET = preload("res://Weapons/Bullet.tscn")

export var max_ammo = 50
var ammo = max_ammo
export var aiming_speed = 10
export var damage = 25
export var bullet_speed = 30
export var bullet_lifespan = 0.5
export var fire_rate = 0.12
var parent

var can_fire = true
var reloading = false

onready var muzzle = $Muzzle
onready var healthbar = $HealthBar
onready var ammobar = $AmmoBar

var enemies = []

func _physics_process(delta):
	if enemies.size():
		if is_instance_valid(enemies.front()): #is valid instance
			# Attack enemies in order of them entering the area
			slowly_aim_at_target(enemies.front(), delta)
		else:
			enemies.pop_front() # if the enemy has died, remove him from the array
		if can_fire:
			fire()

func slowly_aim_at_target(target, delta):
	var target_pos = target.global_transform.origin
	var current_dir = global_transform
	var target_dir = global_transform.looking_at(target_pos, Vector3.UP)
	global_transform = current_dir.interpolate_with(target_dir, aiming_speed*delta)
	

func fire():
	shoot_bullet()
	
	ammo -= 1
	ammobar.update_progressbar(ammo,max_ammo)
	if ammo == 0:
		queue_free()
		return
		
	$AudioStreamPlayer3D.stream = load("res://Assets/sounds/gunshot.wav")
	$AudioStreamPlayer3D.play()
	
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true

func shoot_bullet():
	var instance = BULLET.instance()
	var scene_root = get_node("/root/World")
	instance.global_transform = muzzle.global_transform
	instance.damage = damage
	instance.parent = self
	scene_root.add_child(instance)

func _on_Area_body_entered(body):
	# TODO make sure to exclude parent from enemies
	if body is Bot:
		enemies.append(body)

func _on_Area_body_exited(body):
	if body is Bot:
		enemies.erase(body)

var current_health = 100
func take_damage(damage):
	if current_health > 0:
		current_health -= damage
		healthbar.update_progressbar(current_health,100)
		if current_health <= 0: 
			queue_free()
