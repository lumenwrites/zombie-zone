extends RigidBody

export var max_damage = 100
export var min_damage = 50
export var max_range = 5.0
export var explosion_delay = 2.0
export var push_force = 5
var exploded = false

onready var damage_area = $DamageArea

func _ready():
	damage_area.scale *= max_range
	yield(get_tree().create_timer(explosion_delay), "timeout")
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
			push(body)
	$Mesh.hide()
	spawn_explosion(global_transform.origin)
	queue_free()

onready var EXPLOSION = preload("res://FX/Explosion.tscn")
func spawn_explosion(pos):
	var instance = EXPLOSION.instance()
	instance.global_transform.origin = pos
	get_node("/root/World").add_child(instance)


func push(body):
	if "vel" in body and not body is Player:
		var dir = global_transform.origin.direction_to(body.global_transform.origin) * Vector3(1,0,1)
		dir = dir.normalized()
		body.vel += dir*push_force
