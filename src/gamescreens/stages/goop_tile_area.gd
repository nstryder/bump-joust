extends Area2D
class_name GoopTileArea

# Collision layers...
# Goop should affect: Bouncy & Chargey
# Good should exclude: Slippy 

# Arena should always affect: Bouncy Slippy Chargey

# Bouncy prevents collision by disabling layer 1...
# Bouncy can bypass goop on jump...

# Goop on its own layer?


const SELF_SCENE = preload("uid://cm1uokma5x2ff")

@onready var timer: Timer = $Timer

static func construct(damping: float = 0.0) -> GoopTileArea:
	var instance: GoopTileArea = SELF_SCENE.instantiate()
	instance.linear_damp = damping
	return instance
