extends Area


onready var pickup_audio = $PickupAudio
onready var animation = $AnimationPlayer

var weapon_data = {
	"name": "Ammo" # for InteractionArea to be able to show the tooltip
}

func _ready():
	animation.play("spin")

func use(body):
	if body.get_node("WeaponSwitcher").pickup_ammo_box():
		pickup_audio.play()
		hide()

func _on_AmmoBox_body_entered(body):
	if  body is Player and body.get_node("WeaponSwitcher").pickup_ammo_box():
		pickup_audio.play()
		hide()

func _on_PickupAudio_finished():
	queue_free()




