## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends LPCSpriteLayer
class_name LPCSpriteLayerOversize

const _offsets := {
	"thrust":-4*64,
	"slash":-12*64
}

func _init():
	._init()
	offset = -Vector2(64,64)
	region_rect = Rect2(0,0,192,192)

func copy_atlas_rects(parent_texture : AtlasTexture):
	var anim_offset = _offsets[blueprint_layer.oversize_animation]
	var pos = parent_texture.region.position + Vector2(0, anim_offset)
	if pos.y >= 0 and pos.y < texture.get_size().y:
		region_rect.position = pos * 3.0
		visible = true
	else:
		visible = false
