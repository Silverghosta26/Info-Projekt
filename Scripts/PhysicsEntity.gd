extends CharacterBody2D
class_name PhysicsEntity

# Physik-Konstanten
const jump_speed = 1.5
const SPEED = 190.0 
const JUMP_VELOCITY = -320.0 * jump_speed 
const ACCEL_NORMAL = 1000.0  
const FRICTION_NORMAL = 1000.0
const ACCEL_ICE = 400.0
const FRICTION_ICE = 50.0
const WATER_GRAVITY = 300.0
const WATER_SPEED = 120.0
const WATER_ACCEL = 600.0
const WATER_FRICTION = 400.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER_TIME := 0.03
const SWAP_TIMER = 0.5

# Zustandsvariablen
var watermove: bool = false
var icemove: bool = false
var speed_multiplier := 1.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_ice := false
var was_in_water := false
var air_1 = false
var swap_timer := 0.0


# Tile Definitionen 
var ice_tiles = [
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(6, 2)
]

var water_tiles = [
	Vector2i(4, 9),
	Vector2i(4, 10),
	Vector2i(6, 9),
	Vector2i(6, 10)
]
var spike_tiles = [
	Vector2i(12, 1)
]
var slime_tiles = [
	Vector2i(12, 0)
]
var air_1_tiles = [
	Vector2i(12, 4)
]
var tj = [
	Vector2i(13, 0)
	]

func update_timers(delta,wants_to_jump):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	if  air_1:
		swap_timer = SWAP_TIMER
	else:
		swap_timer = max(swap_timer - delta, 0.0)

	if wants_to_jump:
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

@onready var tilemaps = [
	get_tree().current_scene.find_child("tiles", true, false) if get_tree().current_scene else null,
	get_tree().current_scene.find_child("visuals", true, false) if get_tree().current_scene else null
].filter(func(tm): return tm != null) 

func apply_physics(delta: float, input_dir: Vector2, wants_to_jump: bool):
	update_timers(delta, wants_to_jump)
	apply_gravity(delta)
	
	if not watermove and jump_buffer_timer > 0.0 and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		was_on_ice = icemove

	if watermove:
		velocity.x = move_toward(velocity.x, input_dir.x * WATER_SPEED, WATER_ACCEL * delta)
		velocity.y = move_toward(velocity.y, input_dir.y * WATER_SPEED, WATER_ACCEL * delta)
	else:
		var use_ice = icemove or (not is_on_floor() and was_on_ice)
		var accel = ACCEL_ICE if use_ice else ACCEL_NORMAL
		var friction = FRICTION_ICE if use_ice else FRICTION_NORMAL
		var target_x = input_dir.x * SPEED * speed_multiplier
		velocity.x = move_toward(velocity.x, target_x, (accel if input_dir.x != 0 else friction) * delta)

	move_and_slide()
	update_tile_state()
	handle_water_exit()



func apply_gravity(delta):
	if watermove:
		velocity.y += WATER_GRAVITY * delta
	elif not is_on_floor():
		
		if air_1 or swap_timer > 0.0:
			velocity -= get_gravity() * delta * jump_speed * 0.5
		else:
			velocity += get_gravity() * delta * jump_speed

func update_tile_state():
	icemove = false
	watermove = false
	check_tiles_at_position(global_position + Vector2(0, 10))
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is TileMap:
			var tile_pos = collider.local_to_map(collider.to_local(collision.get_position() - collision.get_normal() * 2))
			handle_tile(collider.get_cell_atlas_coords(tile_pos))

func check_tiles_at_position(pos):
	for tm in tilemaps:
		if tm: handle_tile(tm.get_cell_atlas_coords(tm.local_to_map(tm.to_local(pos))))

func handle_tile(atlas_coords):
	if atlas_coords in ice_tiles: icemove = true
	if atlas_coords in water_tiles: watermove = true
	if atlas_coords in air_1_tiles: air_1 = true
	else: air_1 = false
	if atlas_coords in spike_tiles: get_tree().call_deferred("reload_current_scene")
	if atlas_coords in tj: velocity.y = -velocity.y

func handle_water_exit():
	if was_in_water and not watermove and velocity.y != 0: velocity.y = -300
	was_in_water = watermove
	
func check_enemy_stomp():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is PhysicsEntity and collider != self:
			if collision.get_normal().dot(Vector2.UP) > 0.5:
				if collider.has_method("die"):
					collider.die()
				velocity.y = JUMP_VELOCITY * 0.8 
				return true
	return false
