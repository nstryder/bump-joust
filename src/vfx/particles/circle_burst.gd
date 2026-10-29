extends CPUParticles2D
class_name ParticleCircleBurst


const SELF_SCENE = preload("uid://bih6hktyc36cn")


static func construct() -> ParticleCircleBurst:
	var instance: ParticleCircleBurst = SELF_SCENE.instantiate()
	instance.finished.connect(instance.queue_free)
	return instance
