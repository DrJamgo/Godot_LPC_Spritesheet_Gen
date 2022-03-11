tool
extends SpriteFrames
class_name LPCSpriteBlueprint, 'lpc_icon_spec.png'

export(String, 'male', 'female', 'child', 'pregnant', 'muscular') var body_type := 'male'
export(Array, Resource) var layers 

var rootpath = self.get_script().get_path().get_base_dir() + "/lpc_spritesheets"
var baked_texture := ImageTexture.new()
var is_changed = true

func _init():
    if animations.size() == 1:
        animations = preload("res://addons/lpc_spritesheet_gen/LPCFrames.tres").animations.duplicate(true)
    _set_atlas(preload("res://addons/lpc_spritesheet_gen/lpc_char_ss_template.png"))

func _get_index_by_z(z : int):
    for i in range(0, layers.size()):
        if (layers[i] as LPCSpriteLayer).zorder > z:
            return i
    return layers.size()

func add_layers(json_data : Dictionary, _variant : String):
    var layerIdx = 1
    var layerPos = []
    while ('layer_' + String(layerIdx)) in json_data:
        var layername = 'layer_' + String(layerIdx)
        var new_layer = LPCSpriteLayer.new()
        new_layer.json_data = json_data
        new_layer.body = body_type
        new_layer.name = json_data.name
        new_layer.type_name = json_data.type_name
        new_layer.zorder = json_data[layername].zPos
        new_layer.rel_path = (json_data[layername][body_type] + _variant + ".png").replace(' ','_')
        new_layer.abs_path = rootpath + "/spritesheets/" + new_layer.rel_path
        new_layer.variant = _variant
        var index = _get_index_by_z(new_layer.zorder)
        layerPos.append(index)
        layers.insert(index, new_layer)
        layerIdx += 1
    is_changed = true
    emit_changed()
    #_set_atlas(null) # << clear default texture atlas
    return layerPos

func randomize_layer(type_name : String, variants = []):
    for i in range(0, layers.size()):
        if (layers[i] as LPCSpriteLayer).type_name == type_name:
            layers[i] = layers[i].duplicate(false)
            (layers[i] as LPCSpriteLayer).randomize_variant(variants)

func get_textures():
    var list = []
    for layer in layers:
        list.append((layer as LPCSpriteLayer).get_texture())
    return list

func remove_layer(index : int):
    is_changed = true
    layers.remove(index)
    emit_changed()
    
func _set_atlas(atlas : Texture):
    for anim in animations:
        for idx in range(0, get_frame_count(anim.name)):
            var frame = anim.frames[idx].duplicate()
            frame.atlas = atlas
            set_frame(anim.name, idx, frame)

func _bake():
    if layers.size() > 0:
        var image = Image.new()
        var layer0 : Texture = self.layers[0].get_texture()
        image.copy_from(layer0.get_data())
        for z in range(1, layers.size()):
            var layer = layers[z].get_texture()
            print(String((layer as Texture).get_data().get_format()))
            image.blend_rect(layer.get_data(), Rect2(Vector2(0,0), layer.get_size()), Vector2(0,0))
        baked_texture.create_from_image(image, 0)
        print(baked_texture.to_string())
        
func get_baked():
    if is_changed:
        is_changed = false
        _bake()
    return baked_texture

func set_baked(baked_texture : Texture):
    _set_atlas(baked_texture)
    emit_changed()
