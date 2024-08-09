extends CharacterBody3D

# How fast the player moves in meters per second.
const SPEED = 1.0
const MAXSPEED = Vector3(15,15,15)
# The downward acceleration when in the air, in meters per second squared.
#@export var fall_acceleration = 75

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x*0.01)
			camera.rotate_x(-event.relative.y*0.01)
func _physics_process(delta):
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	var direction = Vector3.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("backward"):
		direction.z += 1
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("up"):
		direction.y += 1
	if Input.is_action_pressed("down"):
		direction.y -= 1
	direction = neck.transform.basis * direction.normalized()
	if direction:
		velocity += direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED*4)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		#$".".basis = Basis.looking_at(direction)

	# Ground Velocity
	#target_velocity.x = direction.x * speed
	#target_velocity.y = direction.y * speed
	#target_velocity.z = direction.z * speed

	# Vertical Velocity
	#if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
	#	target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	#velocity = target_velocity
	move_and_slide()
