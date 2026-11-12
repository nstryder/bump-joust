extends CPUParticles2D
class_name RingOutParticles

const SELF_SCENE = preload("uid://dn0nrv0s33fwb")


static func construct(blast_direction: Vector2) -> RingOutParticles:
	var instance: RingOutParticles = SELF_SCENE.instantiate()
	instance.direction = blast_direction
	return instance


func _on_finished() -> void:
	queue_free()
