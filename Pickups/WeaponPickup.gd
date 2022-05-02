class_name WeaponPickup
extends Area

# Fists, Sword, Gun, Shotgun, Assault Rifle, Sniper Rifle, Grenade
export(String, "Sword", "Gun", "Shotgun", "Assault Rifle", "Sniper Rifle", "Grenade", "Rocket Launcher", "Mine", "Sentry", "Air Strike", "Health Pack") var weapon_type

const WEAPON_MODELS = {
	"Sword": preload("res://assets/weapons/sword.obj"),
	"Gun": preload("res://assets/weapons/gun.obj"),
	"Shotgun": preload("res://assets/weapons/shotgun.obj"),
	"Assault Rifle": preload("res://assets/weapons/assault-rifle.obj"),
	"Sniper Rifle": preload("res://assets/weapons/sniper-rifle.obj"),
	"Grenade": preload("res://assets/weapons/grenade.obj"),
	"Mine": preload("res://assets/weapons/mine.obj"),
	"Sentry": preload("res://assets/weapons/sentry.obj"),
	"Rocket Launcher": preload("res://assets/weapons/rocket-launcher.obj"),
	"Air Strike": preload("res://assets/weapons/air-strike-button.obj"),
	"Health Pack": preload("res://assets/environment/crate-health.obj")
}
var material = preload("res://assets/materials/lowpoly_material.tres")
var weapon_data

onready var weapon_mesh = $WeaponModel/Mesh
onready var pickup_audio = $PickupAudio
onready var animation = $AnimationPlayer

func _ready():
	# If I spawn weapon pickup as I drop the weapon, I'll set it's weapon type when I'm instancing it.
	# If I manually add weapon pickup to the scene, I'll take it from the list of constants
	if not weapon_data:
		weapon_data = Constants.WEAPONS[weapon_type]
	weapon_mesh.mesh = WEAPON_MODELS[weapon_data.name]
	if weapon_data.name in ["Health Pack", "Ammo Box", "Grenade", "Air Strike", "Mine"]:
		weapon_mesh.translation.z = 0
	if weapon_data.name in ["Grenade", "Air Strike", "Mine"]:
		weapon_mesh.rotation.x = 45
	if weapon_data.name in ["Grenade", "Air Strike"]:
		weapon_mesh.scale *= 3
	if weapon_data.name in ["Sentry"]:
		weapon_mesh.scale *= 0.5

	weapon_mesh.material_override = material
	animation.play("spin")

func use(body):
	if body.get_node("WeaponSwitcher").swap_weapon(weapon_data):
		pickup_audio.play()
		hide()

func _on_WeaponPickup_body_entered(body):
	if body is Player and  body.get_node("WeaponSwitcher").pickup_weapon(weapon_data):
		pickup_audio.play()
		hide()


func _on_PickupAudio_finished():
	queue_free()



