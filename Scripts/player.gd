extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Beschleunigung & Reibung
const ACCEL_NORMAL = 1000.0
const FRICTION_NORMAL = 1000.0

const ACCEL_ICE = 400.0
const FRICTION_ICE = 50.0
var watermove: bool = false
var icemove: bool = false
var speed_multiplier := 1.0

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
	check_tile_below()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	var accel = ACCEL_ICE if icemove else ACCEL_NORMAL
	var friction = FRICTION_ICE if icemove else FRICTION_NORMAL

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
