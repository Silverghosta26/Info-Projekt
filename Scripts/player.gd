extends CharacterBody2D

const jump_speed = 1.5

const SPEED = 190.0 
const JUMP_VELOCITY = -320.0 * jump_speed 

# Beschleunigung & Reibung
const ACCEL_NORMAL = 1000.0  
const FRICTION_NORMAL = 1000.0

const ACCEL_ICE = 400.0
const FRICTION_ICE = 50.0
var watermove: bool = false
var icemove: bool = false
var speed_multiplier := 1.0

const COYOTE_TIME := 0.05
const JUMP_BUFFER_TIME := 0.03

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var was_on_ice := false

var input_enabled = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var tilemap = get_tree().current_scene.find_child("tiles", true, false)
@onready var hitbox: CollisionShape2D = $hitbox
@onready var hurtbox: CollisionShape2D = $hurtbox

# eingabe für ice tiles
var ice_tiles = [
	Vector2i(6, 0),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(6,2)
]

var water_tiles = [
	
	Vector2i(4,9),
	Vector2i(4,10),
	Vector2i(6,9),
	Vector2i(6,10)
]

func _physics_process(delta: float) -> void:
	
	if not input_enabled:
		return
	
	# Update timer für Coyote Time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# Update Jump Buffer wenn Taste gedrückt
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * jump_speed 

	# Handle jump: erlauben wenn entweder auf dem Boden ODER in Coyote Time, und ein Buffered Jump vorliegt
	if jump_buffer_timer > 0.0 and (is_on_floor() or coyote_timer > 0.0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		
		was_on_ice = icemove
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("goleft", "goright")

	if Input.is_action_pressed("ducken"):
		hurtbox.disabled = true
		speed_multiplier = 0.5  
		#print("disabled")
	else:
		hurtbox.disabled = false
		speed_multiplier = 1.0
		#print("enabled")

	# flip sprite depending on direction
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0


	var anim = ""

	if not is_on_floor():
		anim = "jump"
	elif Input.is_action_pressed("ducken"):
		anim = "duck"
	elif direction == 0:
		anim = "idle"
	else:
		anim = "run"

	animated_sprite_2d.play(anim)

	# Eis oder normale Werte
	var use_ice_physics = icemove or (not is_on_floor() and was_on_ice)

	var accel = ACCEL_ICE if use_ice_physics else ACCEL_NORMAL
	var friction = FRICTION_ICE if use_ice_physics else FRICTION_NORMAL

	# TARGET SPEED
	var target_velocity_x = direction * SPEED * speed_multiplier

	# bewegung
	if direction != 0:
		velocity.x = move_toward(velocity.x, target_velocity_x, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	
	check_tile_below() # um  zu prüfen welche tile unter dem player ist etc




func check_tile_below():	

	icemove = false
	watermove = false

	var left = global_position + Vector2(-5, 13) #nimmt die player position und added 5 bzw -5 um kante des spieler hitbox zu erreichen
	var right = global_position + Vector2(5, 13) #added 13 bei beiden umuntere kante des spieler bzw den block darunter zu erreichen

	var cell_left = tilemap.local_to_map(tilemap.to_local(left)) #methode die den wert  von oben mit daten aller plazierten tiles vergleicht
	var cell_right = tilemap.local_to_map(tilemap.to_local(right))

	var tile_left = tilemap.get_cell_source_id(cell_left) #holt sich die source id falls es einen wert/input von oben bekommt
	var tile_right = tilemap.get_cell_source_id(cell_right)

	if tile_left != -1 or tile_right != -1:  #beispiel methode, momnentan unrelewand
		#print("Auf Boden")
		pass

	if tile_left != -1: #falls methode oben wert bekommt wird atlascoo über tilemap abgefragt anhand von wert der 2. methode
		var atlas = tilemap.get_cell_atlas_coords(cell_left)
		handle_tile(atlas)

	if tile_right != -1:
		var atlas = tilemap.get_cell_atlas_coords(cell_right) #gleiches wie oben nur rechter punkt shatt links
		handle_tile(atlas)

	else: #beispielmethode, momentan unrelewand
		#print("In der Luft")
		pass

func handle_tile(atlas_coords): #kann aktionen anhand der ergebnisse von oben ausfürhen
	if atlas_coords in ice_tiles:
		icemove = true
	if atlas_coords in water_tiles:
		watermove = true

func disable_input_for(seconds: float) -> void:
	input_enabled = false
	await get_tree().create_timer(seconds).timeout
	input_enabled = true
