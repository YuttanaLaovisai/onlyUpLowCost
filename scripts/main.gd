extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $player.global_position.y < -10:
		$player.global_position = Vector3(0,2,0)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$player/CanvasLayer/Label.visible = true
