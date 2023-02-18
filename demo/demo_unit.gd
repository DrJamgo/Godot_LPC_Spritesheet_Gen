extends Node2D

var attacking = false

func _on_animation_climax(animation_name):
	if animation_name == "slash":
		var weapon_layers = $LPCSprite.get_layers(["weapon"])
		var tween = get_tree().create_tween()
		tween.set_parallel()
		for layer in weapon_layers:
			tween.tween_method(layer, "set_glow", Color(1,0,0,1), Color(1,0,0,0), 0.5)

func _ready():
	$LPCSprite.connect("animation_climax", self, "_on_animation_climax")

func _play_and_wait(anim_name : String):
	attacking = true
	$LPCSprite.set_anim(anim_name)
	yield($LPCSprite, "animation_finished")
	attacking = false

func _process(delta):
	$Label.text = $LPCSprite.anim
	
	if not attacking:
		var velocity = get_local_mouse_position()
		if velocity.length() > 1.0:
			if velocity.length() < 16.0:
				velocity = velocity.normalized() * 16.0
			velocity = velocity.clamped(96.0)
			position += velocity * delta
			$LPCSprite.animate_movement(velocity)
		else:
			$LPCSprite.set_anim("idle")
			
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			_play_and_wait("slash")
