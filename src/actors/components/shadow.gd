extends Node2D
class_name Shadow

const SELF_SCENE = preload("uid://c4rbdewnrruy3")

static func construct() -> Shadow:
	return SELF_SCENE.instantiate()
