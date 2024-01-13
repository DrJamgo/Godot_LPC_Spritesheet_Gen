@tool
## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

extends Resource
class_name LPCSpriteBlueprintLayer

@export var zorder := 10
@export var body := "male"     # Type of Body
@export var name := "Template" # From JSON Data
@export var type_name := "body" # From JSON Data
@export var oversize_animation: String = ""
@export var variant: String = "0" # From Selection
@export var abs_path := ""
@export var rel_path := ""

@export var texture: Texture2D: 
	get: 
		if !texture:
			load_texture()
		return texture

@export var material: Material = preload("../lpc_layers_material_shader.tres"): 
	set(new_material):
		material = new_material
		emit_changed()

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
