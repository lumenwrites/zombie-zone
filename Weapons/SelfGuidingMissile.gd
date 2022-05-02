extends Area

export (float) var steer_force = 5
export var speed = 10 # 30 # 50
export var max_damage = 150
export var min_damage = 25
export var max_range = 4.0
var exploded = false

var max_lifespan = 20.0
var vel = Vector3()
var parent
var acc = Vector2()
var target

onready var damage_area = $DamageArea
onready var lifespan = $Lifespan

func _ready():
	lifespan.wait_time = max_lifespan
	lifespan.start()
	damage_area.scale *= max_range
	
func _physics_process(delta):
	vel = -global_transform.basis.z * speed
	global_transform.origin += vel * delta
	look_at(global_transform.origin+vel, Vector3.UP)
	return
	if target:
		steer(target, delta)
	if not target:
		vel = -global_transform.basis.z * speed
		
	
	avoid_obstacles(delta)
	global_transform.origin += vel * delta
	look_at(global_transform.origin+vel, Vector3.UP)

func _on_TargetArea_body_entered(body):
	if body == parent: return
	var is_living_target = body is Bot or body is Player # not a crate
	if not target and is_living_target :
		target = body

func steer(target, delta):
	var my_pos = global_transform.origin
	var target_pos = target.global_transform.origin+Vector3.UP*0.7
	var target_direction = my_pos.direction_to(target_pos)
	var current_direction = -global_transform.basis.z
	if my_pos.distance_to(target_pos) > 0.5:
		vel = lerp(current_direction, target_direction, steer_force*delta).normalized() * speed
	vel *= Vector3(1,0,1) # make it horizontal until I find the right way, bots are  aiming down TODO
	
	# rotation = vel.angle()

func avoid_obstacles(delta):
	for raycast in $Raycasts.get_children():
		if raycast.is_colliding():
			if raycast.get_collider().has_method("take_damage"): return # don't steer away from targets
			vel += raycast.global_transform.basis.z*2

func _on_SelfGuidingMissile_body_entered(body):
	if body == parent: return
	explode()


func explode():
	if exploded: return
	exploded = true
	var bodies_within_range = damage_area.get_overlapping_bodies()
	for body in bodies_within_range:
		if body.has_method("take_damage"):
			var distance = (body.global_transform.origin - global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			body.take_damage(decayed_damage)
	$Rocket.hide()
	spawn_explosion(global_transform.origin)
	queue_free()

onready var EXPLOSION = preload("res://FX/Explosion.tscn")
func spawn_explosion(pos):
	var instance = EXPLOSION.instance()
	instance.global_transform.origin = pos
	get_node("/root/World").add_child(instance)

func _on_SelfGuidingMissile_area_entered(area):
	return
	if area is Bullet:
		explode()
		area.queue_free()

func _on_Lifespan_timeout():
	queue_free()

