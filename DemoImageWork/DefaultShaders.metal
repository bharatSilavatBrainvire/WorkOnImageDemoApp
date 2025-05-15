//
//  DefaultShaders.metal
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    float4 positions[4] = {
        {-1.0, -1.0, 0.0, 1.0},
        { 1.0, -1.0, 0.0, 1.0},
        {-1.0,  1.0, 0.0, 1.0},
        { 1.0,  1.0, 0.0, 1.0}
    };

    float2 texCoords[4] = {
        {0.0, 1.0},
        {1.0, 1.0},
        {0.0, 0.0},
        {1.0, 0.0}
    };

    VertexOut out;
    out.position = positions[vertexID];
    out.texCoord = texCoords[vertexID];
    return out;
}

fragment float4 fragment_erase(VertexOut in [[stage_in]],
                               texture2d<float> source [[texture(0)]],
                               texture2d<float> brush [[texture(1)]],
                               constant float2& erasePoint [[buffer(0)]]) {

    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

    float2 coord = in.texCoord * float2(source.get_width(), source.get_height());
    float2 delta = coord - erasePoint;
    float dist = length(delta);

    float brushRadius = float(brush.get_width()) / 2.0;

    if (dist < brushRadius) {
        return float4(0.0, 0.0, 0.0, 0.0); // Erased to transparent
    } else {
        return source.sample(textureSampler, in.texCoord);
    }
}
