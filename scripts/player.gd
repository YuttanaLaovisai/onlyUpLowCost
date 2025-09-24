extends CharacterBody3D

@onready var pivot = $Pivot
@onready var camera = $Pivot/Camera3D
@onready var anim = $character/AnimationPlayer

var yaw = 0.0
var pitch = 0.0

@export var speed = 5.0
var is_jumping = false

func _ready() -> void:
	anim.play("2") # idle
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * 0.002
		pitch -= event.relative.y * 0.002
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(50))
		rotation.y = yaw
		pivot.rotation.x = pitch

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shift"):
		$character/AnimationPlayer.speed_scale = 2.0
		speed *= 2
	if Input.is_action_just_released("shift"):
		$character/AnimationPlayer.speed_scale = 1.0
		speed /= 2

func _physics_process(delta: float) -> void:
	# แรงโน้มถ่วง
	if not is_on_floor():
		velocity += get_gravity() * delta

	# กระโดด
	if Input.is_action_just_pressed("space") and is_on_floor():
		is_jumping = true
		$character/AnimationPlayer.speed_scale = 1.5
		anim.play("jump")
		velocity.y = 4.5
		await $character/AnimationPlayer.current_animation_changed
		$character/AnimationPlayer.speed_scale = 1
	

	# การเคลื่อนที่
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if not is_jumping: # ❌ ห้ามเล่นทับ jump
		if direction:
			anim.play("walking")
		else:
			anim.play("2") # idle

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

	# ถ้าลงพื้นแล้ว หลังจาก jump ให้กลับมา idle
	if is_on_floor() and is_jumping and velocity.y <= 0:
		is_jumping = false
		anim.play("2")
