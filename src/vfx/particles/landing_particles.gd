extends CPUParticles2D
class_name LandingParticles
const SELF_SCENE = preload("uid://cpa3c1njodgpa")
static func construct() -> LandingParticles:
	var instance: LandingParticles = SELF_SCENE.instantiate()
	instance.finished.connect(instance.queue_free)
	return instance
