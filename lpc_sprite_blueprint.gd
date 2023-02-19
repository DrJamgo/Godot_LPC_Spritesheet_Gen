## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends SpriteFrames
class_name LPCSpriteBlueprint, 'internal/lpc_icon_spec.png'

export(Array, Resource) var layers 
export(String) var resources_url : String
export(String) var source_url : String
export(String, MULTILINE) var credits_txt : String

func _on_layer_changed():
	emit_changed()

func _init():
	if animations.size() == 1:
		animations = preload("internal/lpc_frames.tres").animations.duplicate(true)
	_set_atlas(preload("internal/lpc_char_ss_template.png"))

func _get_index_by_z(z : int):
	for i in range(0, layers.size()):
		if (layers[i] as LPCSpriteBlueprintLayer).zorder > z:
			return i
	return layers.size()

func add_layers(_layers : Array):
	var layerPos = []
	for layer in _layers:
		var index = _get_index_by_z(layer.zorder)
		layerPos.append(index)
		layers.insert(index, layer)
		layer.connect("changed", self, "_on_layer_changed")
	_set_atlas(null) # << clear default texture atlas
	emit_changed()
	return layerPos

func get_textures():
	var list = []
	for layer in layers:
		list.append((layer as LPCSpriteBlueprintLayer).get_texture())
	return list

func remove_layer(index : int):
	layers.remove(index)
	emit_changed()
	
func _set_atlas(atlas : Texture):
	for anim in animations:
		for idx in range(0, get_frame_count(anim.name)):
			var frame = anim.frames[idx].duplicate()
			frame.atlas = atlas
			set_frame(anim.name, idx, frame)
