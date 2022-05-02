extends RigidBody

export var max_damage = 150
export var min_damage = 50
export var max_range = 5.0
export var explosion_delay = 0.5
var exploded = false

onready var damage_area = $DamageArea

func _ready():
	damage_area.scale *= max_range

func explode():
	if exploded: return
	exploded = true
	# yield(get_tree().create_timer(explosion_delay), "timeout")
	var bodies_within_range = damage_area.get_overlapping_bodies()
	for body in bodies_within_range:
		if body.has_method("take_damage"):
			var distance = (body.global_transform.origin - global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			body.take_damage(decayed_damage)
	$Mesh.hide()
	spawn_explosion(global_transform.origin)
	queue_free()

onready var EXPLOSION = preload("res://FX/Explosion.tscn")
func spawn_explosion(pos):
	var instance = EXPLOSION.instance()
	instance.global_transform.origin = pos
	get_node("/root/World").add_child(instance)


export var max_health = 50.0
var current_health = max_health

func take_damage(damage):
	if current_health > 0:
		current_health -= damage
		$HealthBar.update_progressbar(current_health, max_health)
		if current_health <= 0: 
			explode()
			$HealthBar.update_progressbar(current_health, max_health)

