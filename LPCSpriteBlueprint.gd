tool
extends SpriteFrames
class_name LPCSpriteBlueprint, 'lpc_icon_spec.png'

export(String, 'male', 'female', 'child', 'pregnant', 'muscular') var body_type := 'male'
export(Array, Resource) var layers 

var rootpath = "res://assets/lpc_spritesheets/"
var baked_layer := LPCSpriteLayer.new() setget set_baked, get_baked 
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

func add_layers(_layers : Array):
    var layerPos = []
    for layer in _layers:
        var index = _get_index_by_z(layer.zorder)
        layerPos.append(index)
        layers.insert(index, layer)
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
    var texture = ImageTexture.new()
    baked_layer.texture = texture
    baked_layer.name = "baked"
    if layers.size() > 0:
        var image = Image.new()
        var layer0 : Texture = self.layers[0].get_texture()
        image.copy_from(layer0.get_data())
        for z in range(1, layers.size()):
            var layer = layers[z].get_texture()
            print(String((layer as Texture).get_data().get_format()))
            image.blend_rect(layer.get_data(), Rect2(Vector2(0,0), layer.get_size()), Vector2(0,0))
        texture.create_from_image(image)
        
func get_baked():
    if not baked_layer.texture or is_changed:
        is_changed = false
        _bake()
    return baked_layer

func set_baked(baked_layer : LPCSpriteLayer):
    _set_atlas(baked_layer.texture)
    emit_changed()
