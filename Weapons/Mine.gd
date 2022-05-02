extends Area

export var max_damage = 100
export var min_damage = 50
export var max_range = 2
export var explosion_delay = 0.5
var exploded = false
var parent

func _ready():
	$CollisionShape.scale *= max_range


func _on_Mine_body_entered(body):
	# can't do body.has_method("take_damage") because then it'd explode next to turrets/barrels
	# TODO gotta check that the player who drops it doesnt trigger it
	if body is Bot:
		$Tick.play()
		$Light.show()
		yield(get_tree().create_timer(explosion_delay), "timeout")
		explode()


func explode():
	if exploded: return
	exploded = true
	var bodies_within_range = get_overlapping_bodies()
	for body in bodies_within_range:
		if body.has_method("take_damage"):
			var distance = (body.global_transform.origin - global_transform.origin).length()
			var decayed_damage = range_lerp(distance, 0, max_range, max_damage, min_damage)
			print("mine deal damage ", decayed_damage)
			body.take_damage(decayed_damage)
	spawn_explosion(global_transform.origin)
	queue_free()

onready var EXPLOSION = preload("res://FX/Explosion.tscn")
func spawn_explosion(pos):
	var instance = EXPLOSION.instance()
	instance.global_transform.origin = pos
	get_node("/root/World").add_child(instance)
