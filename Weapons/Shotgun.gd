extends "res://Weapons/Weapon.gd"


export var number_of_bullets= 16

func fire():
	if not can_fire: return
	if is_reloading: return
	if switcher.get("clip_ammo") == 0:
		reload()
		return


	for i in range(number_of_bullets): 
		muzzle.rotation = Vector3(0,0,0)
		randomize()
		muzzle.rotate_y(deg2rad(rand_range(-spread,spread)))
		spawn_bullet()

	switcher.spend_clip_ammo()
	animation.play("shoot")
	audio_fire.play()

	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout") # wait until timer times out
	can_fire = true
