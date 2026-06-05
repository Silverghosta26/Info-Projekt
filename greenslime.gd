extends Area2D

const  SPEED = 60

var direction = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var rayright: RayCast2D = $rayright
@onready var rayleft: RayCast2D = $rayleft

func  _physics_process(delta: float) -> void:
	
	global_position += Vector2(direction * SPEED * delta,0)


# richtung wechseln 
	if rayright.is_colliding():
		#print("collides right")
		direction = -1

	if rayleft.is_colliding():
		#print("collides left")
		direction = 1

#animation/sprite drehung
	if direction == 1:
		animated_sprite.flip_h = false
	if direction == -1:
		animated_sprite.flip_h = true
