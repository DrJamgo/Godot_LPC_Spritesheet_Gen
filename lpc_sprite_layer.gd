## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends Sprite
class_name LPCSpriteLayer

var blueprint_layer : LPCSpriteBlueprintLayer

func _init():
	region_enabled = true
	centered = false
	
func set_atlas(tex : Texture):
	texture = tex
	
func copy_atlas_rects(parent_texture : AtlasTexture):
	region_rect = parent_texture.region

func set_highlight(color : Color):
	(material as ShaderMaterial).set_shader_param("mixColor", color)

func set_outline(color : Color):
	(material as ShaderMaterial).set_shader_param("outLineColor", color)

func set_outlineSize(size : float):
	(material as ShaderMaterial).set_shader_param("outLineSize", Vector2(size, size))

func set_glow(color : Color):
	(material as ShaderMaterial).set_shader_param("glowColor", color)
