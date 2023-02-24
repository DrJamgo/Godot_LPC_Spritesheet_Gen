// Copyright (C) 2023 Denis Selensky - All Rights Reserved
// You may use, distribute and modify this code under the terms of the MIT license

shader_type canvas_item;
render_mode blend_mix;

uniform vec2 outLineSize  = vec2(1,1);
uniform vec4 outLineColor = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 mixColor     = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 glowColor    = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec2 glowRadius   = vec2(1.0,1.0);

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);
    bool doReplace = false;
    
    float avg = 0.0;
    if(glowColor.a > 0.0) {
        const float kernel_r = 1.0;
        const float kernel_Step = 2.0 / 5.0;
        float num = 0.0;
        for(float y = -kernel_r; y <= kernel_r; y+=kernel_Step) {
            for(float x = -kernel_r; x <= kernel_r; x+=kernel_Step) {
                vec2 offset = vec2(x,y) * glowRadius * outLineSize * TEXTURE_PIXEL_SIZE;
                float dist = max(length(offset), 1.0);
                vec4 c = texture(TEXTURE, UV + offset);
                avg += c.a / dist;
                num += 1.0 / dist;
            }
        }
        avg /= num;
        avg *= 1.0;
    }
    
    if (tcol.a < 1.0)
    {
        for(float y = -1.0; y <= 1.0; y+=1.0) {
            for(float x = -1.0; x <= 1.0; x+=1.0) {
                vec2 offset = vec2(x,y) * outLineSize * TEXTURE_PIXEL_SIZE;
                vec4 c = texture(TEXTURE, UV + offset);
                if(c.a  == 1.0 && any(notEqual(c.rgb, vec3(0.0, 0.0, 0.0)))) {
                    doReplace = true;
                    break;
                }
            }
        }
        if(doReplace) {
            tcol = vec4(glowColor.rgb, avg * glowColor.a);
            tcol = mix(tcol.rgba, outLineColor.rgba, outLineColor.a);
        }
        else {
            //discard;
        }
            
    }
    else {
        tcol += vec4(mix(tcol.rgb, glowColor.rgb, avg), tcol.a) * glowColor.a;
        tcol = vec4(mix(tcol.rgb, mixColor.rgb, mixColor.a), tcol.a);
        //tcol += vec4(glowColor.rgb, 0.0) * avg * glowColor.a;
    }

    COLOR = tcol;
}
