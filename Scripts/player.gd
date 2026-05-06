extends CharacterBody2D

const jump_speed = 1.5

const SPEED = 190.0 
const JUMP_VELOCITY = -320.0 * jump_speed 

# Beschleunigung & Reibung
const ACCEL_NORMAL = 1000.0  
const FRICTION_NORMAL = 1000.0

const ACCEL_ICE = 400.0
const FRICTION_ICE = 50.0

const WATER_GRAVITY = 300.0
const WATER_SPEED = 120.0
const WATER_ACCEL = 600.0
const WATER_FRICTION = 400.0
const SWIM_UP_SPEED = -150.0

const COYOTE_TIME := 0.05
const JUMP_BUFFER_TIME := 0.03

var waterslow := 0.05
var watermove: bool = false
var icemove: bool = false
var speed_multiplier := 1.0

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var was_on_ice := false
var was_in_water := false

var input_enabled = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var tilemaps = [
	get_tree().current_scene.find_child("tiles", true, false),
	get_tree().current_scene.find_child("visuals", true, false)
]

@onready var hitbox: CollisionShape2D = $hitbox
@onready var hurtbox: CollisionShape2D = $hurtbox

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


func _physics_process(delta: float) -> void:
	
	if not input_enabled:
		return

	update_timers(delta)
	apply_gravity(delta)
	handle_jump()

	var input_dir = get_input()

	handle_animation(input_dir.x)
	handle_movement(delta, input_dir)

	move_and_slide()

	update_tile_state()
	handle_water_exit()


# ----------------------------
# TIMER
# ----------------------------
func update_timers(delta):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)


# ----------------------------
# GRAVITY
# ----------------------------
func apply_gravity(delta):
	if watermove:
		velocity.y += WATER_GRAVITY * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta * jump_speed


# ----------------------------
# JUMP
# ----------------------------
func handle_jump():
	if not watermove and jump_buffer_timer > 0.0 and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		was_on_ice = icemove


# ----------------------------
# INPUT
# ----------------------------
func get_input():
	var dir = Vector2.ZERO
	
	dir.x = Input.get_axis("goleft", "goright")

	if watermove:
		dir.y = Input.get_axis("Jump", "ducken")

	if Input.is_action_pressed("ducken"):
		hurtbox.disabled = true
		speed_multiplier = 0.5
	else:
		hurtbox.disabled = false
		speed_multiplier = 1.0

	return dir


# ----------------------------
# ANIMATION
# ----------------------------
func handle_animation(direction_x):
	if direction_x != 0:
		animated_sprite_2d.flip_h = direction_x < 0

	var anim = ""

	if not is_on_floor():
		anim = "jump"
	elif Input.is_action_pressed("ducken"):
		anim = "duck"
	elif direction_x == 0:
		anim = "idle"
	else:
		anim = "run"

	animated_sprite_2d.play(anim)


# ----------------------------
# MOVEMENT
# ----------------------------
func handle_movement(delta, input_dir):
	if watermove:
		var target = input_dir * WATER_SPEED

		velocity.x = move_toward(velocity.x, target.x, WATER_ACCEL * delta)
		velocity.y = move_toward(velocity.y, target.y, WATER_ACCEL * delta)

	else:
		var use_ice = icemove or (not is_on_floor() and was_on_ice)

		var accel = ACCEL_ICE if use_ice else ACCEL_NORMAL
		var friction = FRICTION_ICE if use_ice else FRICTION_NORMAL

		var target_x = input_dir.x * SPEED * speed_multiplier

		if input_dir.x != 0:
			velocity.x = move_toward(velocity.x, target_x, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)


# ----------------------------
# TILE SYSTEM
# ----------------------------
func update_tile_state():
	icemove = false
	watermove = false

	var left = global_position + Vector2(-5, 13)
	var right = global_position + Vector2(5, 13)

	for tilemap in tilemaps:
		check_tilemap(tilemap, left, right)


func check_tilemap(tilemap, left_pos, right_pos):
	if tilemap == null:
		return

	var cell_left = tilemap.local_to_map(tilemap.to_local(left_pos))
	var cell_right = tilemap.local_to_map(tilemap.to_local(right_pos))

	var tile_left = tilemap.get_cell_source_id(cell_left)
	var tile_right = tilemap.get_cell_source_id(cell_right)

	if tile_left != -1:
		var atlas = tilemap.get_cell_atlas_coords(cell_left)
		handle_tile(atlas)

	if tile_right != -1:
		var atlas = tilemap.get_cell_atlas_coords(cell_right)
		handle_tile(atlas)


func handle_tile(atlas_coords):
	if atlas_coords in ice_tiles:
		icemove = true
	if atlas_coords in water_tiles:
		watermove = true


# ----------------------------
# WATER EXIT BOOST
# ----------------------------
func handle_water_exit():
	if was_in_water and not watermove:
		if velocity.y != 0:
			velocity.y = -300

	was_in_water = watermove


# ----------------------------
# INPUT DISABLE
# ----------------------------
func disable_input_for(seconds: float) -> void:
	input_enabled = false
	await get_tree().create_timer(seconds).timeout
	input_enabled = true
