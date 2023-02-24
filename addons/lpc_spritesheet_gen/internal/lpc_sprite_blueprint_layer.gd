## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends Resource
class_name LPCSpriteBlueprintLayer

export(int) var zorder := 10
export(String) var body := "male"     # Type of Body
export(String) var name := "Template" # From JSON Data
export(String) var type_name := "body" # From JSON Data
export(String) var oversize_animation = null
export(String) var variant = "0" # From Selection
export(String) var abs_path := ""
export(String) var rel_path := ""
export(Texture) var texture setget ,get_texture
export(Material) var material = preload("../lpc_layers_material_shader.tres") setget _set_material

func _set_material(new_material : Material):
	material = new_material
	emit_changed()

func load_texture() -> bool:
	var resource_exists = ResourceLoader.exists(abs_path)
	if resource_exists and not texture:
		print("explicit loading from " + abs_path)
		texture = load(abs_path)
		emit_changed()
	return resource_exists

func get_texture():
	if !texture:
		load_texture()
	return texture
	
func _init():
	if abs_path != "":
		print("_init loading from " + abs_path)
		texture = load(abs_path)
