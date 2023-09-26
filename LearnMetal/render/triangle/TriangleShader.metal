//
//  TriangleShader.metal
//  LearnMetal
//
//  Created by ONEMC on 2023/9/1.
//

#include <metal_stdlib>
#include "MST_Triangle.h"

using namespace metal;

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    
    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color; // rgba
    
    /*
     // [[flat]] forbidden interpolation in 'Rasterization stage'
     float4 color [[flat]];
     */
};

vertex RasterizerData
tri_clip_vertexShader(uint vertexid [[vertex_id]],
                      constant TriangleVertex *vertexColor [[buffer(TriangleVertexInputIndexVertices)]])
{
    RasterizerData out;
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = vertexColor[vertexid].position;
    out.color = vertexColor[vertexid].color;
    return out;
}

vertex RasterizerData
tri_pixel_vertexShader(uint vertexID [[vertex_id]],
                      constant TriangleVertex *vertices [[buffer(TriangleVertexInputIndexVertices)]],
                      constant vector_uint2 *viewportSizePointer [[buffer(TriangleVertexInputIndexViewportSize)]])
{
    RasterizerData out;
    // Pass the input color directly to the rasterizer.
    out.color = vertices[vertexID].color;
    
    // Index into the array of positions to get the current vertex.
    // The positions are specified in pixel dimensions (i.e. a value of 100
    // is 100 pixels from the origin).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // Get the viewport size and cast to float.
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    return out;
}

fragment float4 triangle_fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
