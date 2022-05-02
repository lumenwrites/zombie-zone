class_name Bullet
extends Area

const BULLET_HOLE = preload("res://Weapons/BulletHole.tscn")
const BLOOD_SPLATTER = preload("res://FX/BloodSplatter.tscn")
export var speed = 15 # 30 # 50
export var damage = 50
export var push_force = 10
var max_lifespan = 1.0
var vel = Vector3()
var parent

func _ready():
	$BulletTrail.scale.z = 0

func _physics_process(delta):
	global_transform.origin += -global_transform.basis.z * speed * delta
	$BulletTrail.scale.z = lerp($BulletTrail.scale.z, 4, 0.1)
	# $BulletTrail.scale.x = lerp($BulletTrail.scale.x, 0.7, 2*delta)


func _on_Bullet_body_entered(body):
	if body == parent: return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		if body is Bot:
			spawn_blood_splatter(body)
			push(body)

	queue_free()

func spawn_blood_splatter(body):
	var instance = BLOOD_SPLATTER.instance()
	body.add_child(instance)
	instance.global_transform = global_transform
	instance.rotation_degrees.y += 180
	# instance.global_transform.basis = global_transform.basis
	# instance.look_at(parent.global_transform.origin+Vector3.UP*0.7, Vector3.UP)
	# instance.rotate_y(deg2rad(180))
	

func push(body):
	# if "vel" in body and not body is Player:
	if not is_instance_valid(parent): return
	var dir = parent.global_transform.origin.direction_to(body.global_transform.origin) * Vector3(1,0,1)
	dir = dir.normalized()
	body.vel += dir*push_force

func _on_Lifespan_timeout():
	queue_free()
