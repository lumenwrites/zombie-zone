extends Spatial


func _ready():
	$Particles1.emitting = true
	$Particles2.emitting = true
	$Particles1.one_shot = true
	$Particles2.one_shot = true
	$AudioStreamPlayer3D.play()
	# Resumed function '_ready()' after yield
	# don't need it anyway, blood splatter disappears as soon as bot dies, since it's parented to it.
	# yield(get_tree().create_timer(5), "timeout")
	# queue_free()
