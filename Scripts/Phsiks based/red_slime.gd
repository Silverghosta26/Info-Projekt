extends PhysicsEntity

const ENEMY_SPEED = 60.0
var direction = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rayright: RayCast2D = $rayright
@onready var rayleft: RayCast2D = $rayleft

func _init() -> void:
	stompable = false 

func _physics_process(delta: float) -> void:
	if is_alive:
		if rayright.is_colliding():
			direction = -1
		elif rayleft.is_colliding():
			direction = 1
		
		var input_dir = Vector2(direction, 0)
		apply_physics_custom(delta, input_dir)

		animated_sprite.flip_h = (direction == -1)
		
	else:
		animated_sprite.play("die")  

func apply_physics_custom(delta, input_dir):
	update_timers(delta, false)
	apply_gravity(delta)
	velocity.x = input_dir.x * ENEMY_SPEED
	move_and_slide()
	update_tile_state()
	handle_water_exit()

func die():
	is_alive = false 
	await get_tree().create_timer(0.5).timeout
	queue_free()
