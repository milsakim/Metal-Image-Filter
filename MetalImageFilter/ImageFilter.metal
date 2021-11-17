//
//  ImageFilter.metal
//  MetalImageFilter
//
//  Created by HyeJee Kim on 2021/11/17.
//

#include <metal_stdlib>
using namespace metal;

half4 invertColor(half4 color) {
    return half4((1.0 - color.rgb), color.a);
}

kernel void drawWithInvertedColor(texture2d<half, access::read> inTexture [[ texture (0) ]],
                               texture2d<half, access::read_write> outTexture [[ texture (1) ]],
                               uint2 gid [[ thread_position_in_grid ]]) {
    half4 color = inTexture.read(gid).rgba;
    half4 invertedColor = invertColor(color);
    outTexture.write(invertedColor, gid);
}
