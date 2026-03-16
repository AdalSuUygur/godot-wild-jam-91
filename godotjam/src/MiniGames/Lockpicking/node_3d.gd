class_name lockpick extends Node3D

@export var max_range: float = 10.0 # the range in which the sweet spot can go from
@export var sensitivity: float = 0.003 # The sensitivity in which the lockpick moves

@onready var rotate_pivot: Node3D = $lockpick
@onready var keyhole_pivot: Node3D = $keyhole

var is_unlocked: bool = false
var is_turning_keyhole: bool = false

var lockpick_spot: float = 0.0 # the lockpick postion tanges from MIN_RANGE to max_range

var keyhole_rotation_speed: float = 4.0 # the speed in which the keyhole rotates when pressing D

var sweet_spot: float = 0.0 

# The distance to the sweet spot.
# NOTE: Use this variable to scale difficulity, the closer the number to 0 the harder the lockpicking is
var sweet_spot_range: float = 1.0 

const MIN_RANGE: float = 0.0 # i'm not sure why would you change this
const LOCKPICK_SUCCSESS_ZONE: float = -90.0 # the degree in which, the keyhole rotate to considers it has been unlocked

signal unlocked() # a signal emmited when the lock has been unlocked
#------------------------------------------------------------------#
func _ready() -> void:
	# make the lockpick at the center
	lockpick_spot = max_range / 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # capture the mosue (NOTE: you can remove this)
	place_sweetspot()

func _input(event: InputEvent) -> void:
	# if we're mocing the mouse
	if event is InputEventMouseMotion:
		# if the keyhole isn't turning and we haven't unlocked it yet
		if not is_turning_keyhole and not is_unlocked:
			# rotate the lockpick along the z axis AND making sure it dosen't go beyong -90 and 90 degrees
			rotate_pivot.rotate_z(-event.relative.x * sensitivity)
			rotate_pivot.rotation.z = clamp(rotate_pivot.rotation.z, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# we remap the lockpick spot from -90 and 90 to a value that goes from MIN_RANGE to max_range, then we snap it for easier controls
	lockpick_spot = snappedf(remap(rad_to_deg(rotate_pivot.rotation.z), -90, 90, MIN_RANGE, max_range), 0.1)
	
	# self explanatory
	if not is_unlocked:
		_handel_keyhole(delta)

# generating a random number via godot's RandomNumberGenerator class, call this function when you want to reinitialise the sweet spot
func place_sweetspot() -> void:
	var rand_range: RandomNumberGenerator = RandomNumberGenerator.new()
	# snapping the value so the lock dosen't give the player cancer trying to open it
	sweet_spot = snappedf(rand_range.randf_range(MIN_RANGE, max_range), 0.1)
	
	#print("\n\nSweetspot = ",sweet_spot)

func _handel_keyhole(delta: float) -> void:
	# if we're pressing the D button on the keyboard (turning the keyhole) then rotate
	if Input.is_physical_key_pressed(KEY_D):
		keyhole_pivot.rotate_z(-keyhole_rotation_speed * delta)
		is_turning_keyhole = true
	else:
		# otherwise go back to normal rotation
		keyhole_pivot.rotation.z = lerp_angle(keyhole_pivot.rotation.z, 0, 4 * delta)
		is_turning_keyhole = false
	
	# gradually block the keyhole rotation depenting on the distance to the sweetspot
	var distance: float = abs(lockpick_spot - sweet_spot) # the distance to the sweet spot acording to the lockpick position
	# we remap that distance to be in the range from 0 to the succes degree, we also snap it for convience
	var grad_lock: float = snappedf(remap(distance, sweet_spot_range, 0, 0, LOCKPICK_SUCCSESS_ZONE), 0.1)
	# clamping the rotation so we don't go beyond LOCKPICK_SUCCSESS_ZONE
	keyhole_pivot.rotation_degrees.z = clamp(keyhole_pivot.rotation_degrees.z, grad_lock, 0)
	
	# emit the unlocked signal once the keyhole have turned 90 degree
	if rad_to_deg(keyhole_pivot.rotation.z) <= LOCKPICK_SUCCSESS_ZONE:
		unlocked.emit()

func _on_unlocked() -> void:
	is_unlocked = true
	#print("unlocked")
