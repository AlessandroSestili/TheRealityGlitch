extends Area2D

const SPEED := 500.0

var direction := Vector2.RIGHT
var damage    := 20.0
var _bounces  := 0

func _ready() -> void:
	var dot := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 8:
		var a := i * TAU / 8
		pts.append(Vector2(cos(a) * 4, sin(a) * 4))
	dot.polygon = pts
	dot.color = Color(1.0, 0.85, 0.1, 1)
	add_child(dot)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func set_bounces(n: int) -> void:
	_bounces = n

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("wall"):
		if _bounces > 0:
			# Rifletti la direzione rispetto alla normale della collisione
			var space := get_world_2d().direct_space_state
			var query  := PhysicsRayQueryParameters2D.create(
				global_position - direction * 4,
				global_position + direction * 4
			)
			var result := space.intersect_ray(query)
			if result:
				direction = direction.bounce(result.normal)
			_bounces -= 1
		else:
			queue_free()

func _on_VisibleOnScreenNotifier2D_screen_exited() -> void:
	queue_free()
