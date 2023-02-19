## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

extends Node2D

var attacking = false
var facing_direction : Vector2
export(NodePath) var skeleton_node

func _on_animation_climax(animation_name):
	if animation_name == "slash":
		var weapon_layers = $LPCSprite.get_layers(["weapon"])
		var tween = get_tree().create_tween()
		tween.set_parallel()
		for layer in weapon_layers:
			tween.tween_method(layer, "set_glow", Color(1,0,0,1), Color(1,0,0,0), 0.5)
			
		var skeletton = get_node(skeleton_node) as Node2D
		var relative_position_to_skeleton : Vector2 = (skeletton.global_position - global_position)
		var direction_to_skeleton := relative_position_to_skeleton.normalized()
		var dot = direction_to_skeleton.dot(facing_direction)
		if relative_position_to_skeleton.length() < 100.0 and dot > 0.0:
			skeletton.hurt()

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
		facing_direction = velocity.normalized()
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
