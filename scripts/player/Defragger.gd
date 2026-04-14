extends CharacterBody2D

## The Defragger — Player principale.
## Gestisce movimento, dash, shooting e delega gli effetti agli Snippet attivi.

# ---------------------------------------------------------------------------
# Costanti
# ---------------------------------------------------------------------------
const SPEED        := 180.0
const DASH_FORCE   := 450.0
const DASH_DURATION := 0.15
const DASH_COOLDOWN := 0.8

@export var max_hp     := 100.0
@export var fire_rate  := 0.2  # secondi tra un colpo e l'altro

# ---------------------------------------------------------------------------
# Nodi
# ---------------------------------------------------------------------------
@onready var camera:        Camera2D    = $Camera2D
@onready var sprite:        AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_origin:  Marker2D    = $ShootOrigin
@onready var dash_timer:    Timer       = $DashTimer
@onready var cd_timer:      Timer       = $CooldownTimer
@onready var fire_timer:    Timer       = $FireTimer
@onready var hurt_flash:    ColorRect   = $HurtFlash/ColorRect

# ---------------------------------------------------------------------------
# Stato
# ---------------------------------------------------------------------------
var hp          := max_hp
var is_dashing  := false
var can_dash    := true
var dash_dir    := Vector2.ZERO
var _shoot_held := false

# ---------------------------------------------------------------------------
# Risorse proiettile (assegnata dall'editor o da Snippet)
# ---------------------------------------------------------------------------
@export var bullet_scene: PackedScene

# ---------------------------------------------------------------------------
# _ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")
	SystemManager.instability_changed.connect(_on_instability_changed)
	fire_timer.wait_time = fire_rate * SystemManager.get_cooldown_multiplier()
	dash_timer.timeout.connect(_on_DashTimer_timeout)
	cd_timer.timeout.connect(_on_CooldownTimer_timeout)

# ---------------------------------------------------------------------------
# _physics_process
# ---------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_dir * DASH_FORCE
	else:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_dir * SPEED
		_update_animation(input_dir)

	move_and_slide()

	if _shoot_held and fire_timer.is_stopped():
		_shoot()

# ---------------------------------------------------------------------------
# _input
# ---------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and can_dash:
		_start_dash()

	if event.is_action_pressed("ui_accept"):
		_shoot_held = true
	if event.is_action_released("ui_accept"):
		_shoot_held = false

	if event.is_action_pressed("ui_terminal"):
		_open_terminal()

# ---------------------------------------------------------------------------
# Dash
# ---------------------------------------------------------------------------
func _start_dash() -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT if sprite.flip_h == false else Vector2.LEFT

	dash_dir   = dir
	is_dashing = true
	can_dash   = false

	SnippetBus.emit_dash(self, dash_dir)

	dash_timer.start(DASH_DURATION)
	cd_timer.start(DASH_COOLDOWN * SystemManager.get_cooldown_multiplier())

func _on_DashTimer_timeout() -> void:
	is_dashing = false

func _on_CooldownTimer_timeout() -> void:
	can_dash = true

# ---------------------------------------------------------------------------
# Shoot
# ---------------------------------------------------------------------------
func _shoot() -> void:
	if bullet_scene == null:
		return
	var b: Node2D = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = shoot_origin.global_position
	b.direction = (get_global_mouse_position() - shoot_origin.global_position).normalized()
	fire_timer.start(fire_rate * SystemManager.get_cooldown_multiplier())
	SnippetBus.emit_shoot(self, b)

# ---------------------------------------------------------------------------
# Danno
# ---------------------------------------------------------------------------
func take_damage(amount: float) -> void:
	hp -= amount
	SnippetBus.emit_hit_taken(self, amount)
	_screen_shake(4.0, 0.2)
	_flash_hurt()
	if hp <= 0:
		_die()

func _die() -> void:
	SystemManager.end_run(false)
	queue_free()

# ---------------------------------------------------------------------------
# Animazione
# ---------------------------------------------------------------------------
func _update_animation(dir: Vector2) -> void:
	if sprite.sprite_frames == null:
		return
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
	var anim := "run" if dir != Vector2.ZERO else "idle"
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

# ---------------------------------------------------------------------------
# Screen Shake
# ---------------------------------------------------------------------------
func _screen_shake(strength: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(_apply_shake.bind(strength), 0.0, 1.0, duration)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func _apply_shake(t: float, strength: float) -> void:
	camera.offset = Vector2(
		randf_range(-strength, strength),
		randf_range(-strength, strength)
	)

# ---------------------------------------------------------------------------
# Hurt Flash
# ---------------------------------------------------------------------------
func _flash_hurt() -> void:
	hurt_flash.visible = true
	await get_tree().create_timer(0.08).timeout
	hurt_flash.visible = false

# ---------------------------------------------------------------------------
# Terminal
# ---------------------------------------------------------------------------
func _open_terminal() -> void:
	Engine.time_scale = 0.1
	var terminal := get_tree().get_first_node_in_group("terminal")
	if terminal:
		terminal.open()

# ---------------------------------------------------------------------------
# Instabilità
# ---------------------------------------------------------------------------
func _on_instability_changed(value: float) -> void:
	# Shader passato al materiale dello sprite per effetto glitch visivo
	if sprite.material:
		sprite.material.set_shader_parameter("instability", value / 100.0)
