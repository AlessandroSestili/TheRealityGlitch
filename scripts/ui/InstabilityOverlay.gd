extends CanvasLayer

## Overlay schermo globale per gli shader di instabilità.
## Va agganciato a un ColorRect fullscreen con screen_glitch.gdshader.

@onready var overlay: ColorRect = $OverlayRect

func _ready() -> void:
	SystemManager.instability_changed.connect(_on_instability_changed)
	SystemManager.kernel_panic_threshold_reached.connect(_on_threshold)

func _on_instability_changed(value: float) -> void:
	if overlay.material:
		overlay.material.set_shader_parameter("instability", value / 100.0)

func _on_threshold(threshold: int) -> void:
	# Breve flash per segnalare raggiunta soglia
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.4, 0.05)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.1)
