tool
extends Sprite
class_name LPCSpriteLayer

var blueprint_layer : LPCSpriteBlueprintLayer

func _init():
	region_enabled = true
	centered = false
	material = preload("lpc_layers_material_shader.tres")

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

func effect_materialize(color : Color, duration : float):
	color.a = 2.0
	var color_to = color
	color_to.a = 0
	var tween = get_tree().create_tween()
	tween.tween_method(self, "set_glow", color, color_to, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
