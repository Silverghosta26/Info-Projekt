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
var air_2 = false
var air_3 = false
var air_4 = false
var swap_timer1 := 0.0
var swap_timer2 := 0.0
var swap_timer3 := 0.0
var swap_timer4 := 0.0
var is_alive = true
@export var stompable = true
@export var boostable = true
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
var air_2_tiles = [
	Vector2i(13, 4)
]
var air_3_tiles = [
	Vector2i(14, 4)
]
var air_4_tiles = [
	Vector2i(13, 5)
]
var tj = [
	Vector2i(13, 0)
	]


func update_timers(delta,wants_to_jump):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	if  air_1  :
		swap_timer1 = SWAP_TIMER
	else:
		swap_timer1 = max(swap_timer1 - delta, 0.0)
		
	if  air_3  :
		swap_timer3 = SWAP_TIMER
	else:
		swap_timer3 = max(swap_timer3 - delta, 0.0)

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
		var force = (accel if input_dir.x != 0 else friction) * delta
		
		if air_2:
			if velocity.x > target_x and input_dir.x >= 0:
				pass 
			else:
				velocity.x = move_toward(velocity.x, target_x, force)
		elif air_4:
			if velocity.x < target_x and input_dir.x <= 0:
				pass
			else:
				velocity.x = move_toward(velocity.x, target_x, force)
		else:
			velocity.x = move_toward(velocity.x, target_x, force)
		
	apply_gravity(delta)
	
	velocity.x = clamp(velocity.x, -1100.0, 1100.0)
	velocity.y = clamp(velocity.y, -1100.0, 1100.0)
	
	move_and_slide()
	update_tile_state()
	handle_water_exit()


func apply_gravity(delta):
	var grav = get_gravity() * delta * jump_speed
	
	if watermove:
		velocity.y += WATER_GRAVITY * delta
	else:
		
		if air_2:
			velocity.x += grav.y
		elif air_4:
			velocity.x -= grav.y
		
		
		if not is_on_floor():
			if air_1 or swap_timer1 > 0.0:
				velocity.y -= grav.y * 0.5
			elif air_3 or swap_timer3 > 0.0:
				velocity.y += grav.y * 3.0
			elif air_2 or air_4:
				pass 
			else:
				velocity.y += grav.y
		
		
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
	if atlas_coords in air_2_tiles: air_2 = true
	else: air_2 = false
	if atlas_coords in air_3_tiles: air_3 = true
	else: air_3 = false
	if atlas_coords in air_4_tiles: air_4 = true
	else: air_4 = false
	if atlas_coords in spike_tiles: self.die()
	if atlas_coords in tj:
		if velocity.y >400 :
			velocity.y = -velocity.y
		else:velocity.y =-400

func handle_water_exit():
	if was_in_water and not watermove and velocity.y != 0: velocity.y = -300
	was_in_water = watermove
	
func check_enemy_stomp():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is PhysicsEntity and collider != self and collider.stompable == true:
			if collision.get_normal().dot(Vector2.UP) > 0.5:
				if collider.has_method("die"):
					collider.die()
				velocity.y = JUMP_VELOCITY * 0.8 
				return true
	return false

func die():
	is_alive = false
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
