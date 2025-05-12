//
//  ImageShader.metal
//  DemoImageWork
//
//  Created by Bharat Shilavat on 09/05/25.
//

#include <metal_stdlib>
using namespace metal;

// Vertex output structure
struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_passthrough(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment shader for image manipulation
fragment float4 imageShader(VertexOut in [[stage_in]],
                            texture2d<float> texture [[texture(0)]],
                            constant float &brightness [[buffer(0)]],
                            constant float &contrast [[buffer(1)]],
                            constant float &saturation [[buffer(2)]],
                            constant float &exposure [[buffer(3)]],
                            constant float &temperature [[buffer(4)]]) {
    
    // Sample the texture at the input texture coordinates
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float4 color = texture.sample(s, in.texCoord);
    
    // Apply brightness adjustment
    color.rgb += brightness;
    
    // Apply contrast adjustment
    color.rgb = ((color.rgb - 0.5) * max(contrast, 0.0)) + 0.5;

    // Apply saturation adjustment
    float grey = dot(color.rgb, float3(0.3, 0.59, 0.11));  // Luminosity
    color.rgb = mix(float3(grey, grey, grey), color.rgb, saturation);
    
    // Apply exposure adjustment
    color.rgb *= exposure;

    // Temperature adjustment (shifting the red and blue channels)
    color.rgb += float3(temperature, 0, -temperature);  // Basic temperature shift
    
    // Ensure color values are within the valid range [0, 1]
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    return color;
}
