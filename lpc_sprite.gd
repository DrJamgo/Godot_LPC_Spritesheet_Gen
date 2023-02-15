tool
class_name LPCSprite, "internal/lpc_icon.png"
extends AnimatedSprite
#
# This Class can be used to display an animated LPC character spritesheet
# It uses a LPCSpriteBlueprint as "frames" property
#

signal animation_trigger(anim)

export(String, 'down','left','up','right') var dir = 'down' setget set_dir
export(String, 'idle', 'walk', 'stride', 'jog', 'cast', 'slash', 'thrust', 'hurt') var anim = 'idle' setget set_anim

# If enabled: three animations (based on speed) are used: walk, stride, jog
# If disabled: only 'walk' is used with varying animation speed
export(bool) var stride_jog_enabled = false

var _last_frames
const _walk_anim_names = ['walk', 'stride', 'jog']

func _init():
	centered = false
	offset = Vector2(-32,-60)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _last_frames and _last_frames != frames:
		# reconnect if frames object changed (needed for editor)
		_last_frames.disconnect("changed", self, "_reload_layers_from_blueprint")
		frames.connect("changed", self, "_reload_layers_from_blueprint")
		_reload_layers_from_blueprint()
	_last_frames = frames
	var anim_name = anim + "_" + dir
	if animation != anim_name:
		if anim == 'hurt':
			dir = 'down'
			_play('hurt_down')
		else:
			_play(anim_name)

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

#
# Adds the Layers from an additional blueprint.
# This can be used to add e.g. Weopon, Gear, etc.
#
func add_blueprint(blueprint : LPCSpriteBlueprint) -> Array:
	return add_layers(blueprint.layers)

func add_layers(layers : Array) -> Array:
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
	add_child(new_sprite)
	(frames as LPCSpriteBlueprint)._set_atlas(null)
	return new_sprite

func reset():
	stop()
	frame = 0

func set_dir(direction):
	if typeof(direction) == TYPE_VECTOR2:
		direction = _angle_to_dir(direction.angle())
	dir = direction

func set_anim(_anim):
	playing = true
	if anim != _anim:
		anim = _anim
		speed_scale = 1.0

func get_layers(type_filter : Array = []) -> Array:
	var layers_of_type = []
	for child in get_children():
		if child as LPCSpriteLayer:
			if type_filter.empty() or child.blueprint_layer.type_name in type_filter:
				layers_of_type.append(child)
	return layers_of_type
			
func move(direction : Vector2):
	var speed = direction.length()
	set_dir(direction)

	if speed <= 0:
		anim = 'idle'
	else:
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


func _play(_anim : String):
	# This mess is an attempt to blend stride animations changes better together
	if _anim.split("_")[0] in _walk_anim_names and animation.split("_")[0] in _walk_anim_names:
		var factor : float = float(frame) / float(frames.get_frame_count(animation))
		var index := int(round(factor * float(frames.get_frame_count(_anim))))
		animation = _anim
		frame = index
	else:
		animation = _anim
	_on_LPCSprite_frame_changed()

func _on_LPCSprite_frame_changed():
	var blueprint : LPCSpriteBlueprint = (frames as LPCSpriteBlueprint)
	if blueprint:
		var tex = blueprint.get_frame(self.animation, self.frame)
		for child in get_children():
			if child as LPCSpriteLayer:
				child.copy_atlas_rects(tex)
		if anim == "slash" and self.frame == 4:
			emit_signal("animation_trigger", anim)
		elif anim == "thrust" and self.frame == 5:
			emit_signal("animation_trigger", anim)
		elif anim == "shoot" and self.frame == 9:
			emit_signal("animation_trigger", anim)
		elif anim == "cast" and self.frame == 5:
			emit_signal("animation_trigger", anim)
