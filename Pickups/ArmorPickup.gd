extends Area

onready var pickup_audio = $PickupAudio
onready var animation = $AnimationPlayer

var weapon_data = {
	"name": "Armor" # for InteractionArea to be able to show the tooltip
}

func _ready():
	animation.play("spin")

func use(body):
	if body.get_node("Resources").gain_armor(50):
		pickup_audio.play()
		hide()

func _on_Armor_body_entered(body):
	if body is Player and body.get_node("Resources").gain_armor(50):
		pickup_audio.play()
		hide()

func _on_PickupAudio_finished():
	queue_free()


