## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
class_name LPCSprite, "internal/lpc_icon.png"
extends AnimatedSprite
##
## This Class can be used to display an animated LPC character spritesheet
## It uses a LPCSpriteBlueprint as "frames" property
##
## Each layer is kept seperate and can be added/removed or animated at runtime
##


## This signal is emited when non-endless animations reach their 'climax' point
## Use this to deal the damage or loose the arrow. Implemented for
## - slash
## - thrust
## - shoot
## - cast
##
## Note: use animation_finished signal to react to a completed animation
signal animation_climax(animname)

export(String, 'down','left','up','right') var dir = 'down' setget set_dir
export(String, 'idle', 'walk', 'stride', 'jog', 'cast', 'slash', 'thrust', 'hurt') var anim = 'idle' setget set_anim

## If enabled: three animations (based on speed) are used: walk, stride, jog
## If disabled: only 'walk' is used with varying animation speed
export(bool) var stride_jog_enabled = false

var _last_frames
const _walk_anim_names = ['walk', 'stride', 'jog']


func _init():
	centered = false
	offset = Vector2(-32,-60)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _last_frames and _last_frames != frames:
		# reconnect if frames object changed (needed for editor)
		_last_frames.disconnect("changed", self, "_reload_layers_from_blueprint")
		frames.connect("changed", self, "_reload_layers_from_blueprint")
		call_deferred("_reload_layers_from_blueprint")
	_last_frames = frames
	_update_animation()


func _enter_tree():
	if frames:
		frames.connect("changed", self, "_reload_layers_from_blueprint")
	connect("frame_changed", self, "_on_LPCSprite_frame_changed")
	_reload_layers_from_blueprint()
	
	
func _exit_tree():
	if frames:
		frames.disconnect("changed", self, "_reload_layers_from_blueprint")
	disconnect("frame_changed", self, "_on_LPCSprite_frame_changed")


func _get_configuration_warning() -> String:
	if not (frames as LPCSpriteBlueprint):
		return "'frames' property must be of type LPCSpriteBlueprint"
	return ""

## Set direction by providing either:
## - Vector2 (any direction)
## - String (down, up, left, right)
##
func set_dir(direction):
	if typeof(direction) == TYPE_VECTOR2:
		direction = _angle_to_dir(direction.angle())
	dir = direction
	_update_animation()

## Set animation by name and play it, can be one of:
## - idle
## - walk
## - stride
## - hustle
## - slash
## - thrust
## - shoot
## - hurt
func set_anim(_animation_name : String):
	frame = 0
	playing = true
	if anim != _animation_name:
		anim = _animation_name
		speed_scale = 1.0
	_update_animation()

# Takes velocity vector and chooses correct animation from it
# Note: 32px/s is 
func animate_movement(velocity : Vector2):
	set_dir(velocity)
	if velocity.length() > 0:
		var speed := velocity.length()
		if stride_jog_enabled:
			if speed > 48:
				anim = 'jog'
			elif speed > 28:
				anim = 'stride'
			elif speed > 0:
				anim = 'walk'
		else:
			speed_scale = speed / 32
			anim = 'walk'
	else:
		anim = 'idle'
	_update_animation()

## Returns layers matching the optional "type" filter, layers are of type LPCSpriteLayer
## Some type string examples:
## - body
## - head
## - weapon
## - legs
## - hair
## - ...
## Hint: Check the 'type_name' property in the blueprint
func get_layers(type_filter : Array = []) -> Array:
	var layers_of_type = []
	for child in get_children():
		if child as LPCSpriteLayer:
			if type_filter.empty() or child.blueprint_layer.type_name in type_filter:
				layers_of_type.append(child)
	return layers_of_type

## Adds the Layers from an additional blueprint.
## This can be used to add e.g. Weapon, Gear, etc.
## Returns an array of added LPCSpriteLayer(s) for future manipulation
##
func add_blueprint(blueprint : LPCSpriteBlueprint) -> Array:
	return _add_layers(blueprint.layers)

func _add_layers(layers : Array) -> Array:
	var sprite_array := Array()
	for layer in layers:
		sprite_array.append(_add_layer_sprite(layer))
	_on_LPCSprite_frame_changed()
	return sprite_array


func _reload_layers_from_blueprint():
	for child in get_children():
		if child as LPCSpriteLayer:
			remove_child(child)
			child.queue_free()
	var blueprint : LPCSpriteBlueprint = frames
	var has_layers = false
	for layer in blueprint.layers:
		var sprite = _add_layer_sprite(layer)
		has_layers = true
	if has_layers:
		blueprint._set_atlas(null)
	_on_LPCSprite_frame_changed()


func _add_layer_sprite(layer : LPCSpriteBlueprintLayer) -> Sprite:
	var new_sprite = LPCSpriteLayer.new() if (layer.oversize_animation == null) else LPCSpriteLayerOversize.new()
	new_sprite.set_atlas(layer.texture)
	new_sprite.unique_name_in_owner = false
	new_sprite.set_name(layer.type_name)
	new_sprite.offset += self.offset
	new_sprite.centered = centered
	new_sprite.blueprint_layer = layer
	new_sprite.material = layer.material.duplicate()
	new_sprite.texture.flags = Texture.FLAG_MIPMAPS
	add_child(new_sprite)
	(frames as LPCSpriteBlueprint)._set_atlas(null)
	return new_sprite


func _angle_to_dir(_angle):
	var seg1 = PI*2/8
	var seg2 = PI*6/8
	
	if _angle <= seg1 and _angle >= -seg1:
		return 'right'
	elif _angle > seg1 and _angle < seg2:
		return 'down'
	elif _angle <= -seg1 and _angle >= -seg2:
		return 'up'
	else:
		return 'left'


func _update_animation():
	
	var anim_name = anim + "_" + dir
	if animation != anim_name:
		if anim == 'hurt':
			dir = 'down' # 'hurt' is always 'down'
			anim_name = 'hurt_down'
		if frames and frames.has_animation(anim_name):
			# This mess is an attempt to blend stride animations changes better together
			if anim in _walk_anim_names and animation.split("_")[0] in _walk_anim_names:
				var factor : float = float(frame) / float(frames.get_frame_count(animation))
				var index := int(round(factor * float(frames.get_frame_count(anim_name))))
				animation = anim_name
				frame = index
			else:
				animation = anim_name
			_on_LPCSprite_frame_changed()


func _on_LPCSprite_frame_changed():
	var blueprint : LPCSpriteBlueprint = (frames as LPCSpriteBlueprint)
	if blueprint:
		var tex = blueprint.get_frame(self.animation, self.frame)
		for child in get_children():
			if child as LPCSpriteLayer:
				child.copy_atlas_rects(tex)
		if anim == "slash" and self.frame == 4:
			emit_signal("animation_climax", anim)
		elif anim == "thrust" and self.frame == 5:
			emit_signal("animation_climax", anim)
		elif anim == "shoot" and self.frame == 9:
			emit_signal("animation_climax", anim)
		elif anim == "cast" and self.frame == 5:
			emit_signal("animation_climax", anim)
