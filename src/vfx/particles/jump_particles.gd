extends CPUParticles2D
class_name JumpParticles
const SELF_SCENE = preload("uid://cjyi2vso7na0x")
static func construct() -> JumpParticles:
	var instance: JumpParticles = SELF_SCENE.instantiate()
	instance.finished.connect(instance.queue_free)
	return instance
