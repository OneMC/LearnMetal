//
//  MST_Triangle.h
//  LearnMetal
//
//  Created by ONEMC on 2023/8/21.
//

#ifndef MST_Triangle_h
#define MST_Triangle_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs
// match Metal API buffer set calls.
typedef enum {
    TriangleVertexInputIndexVertices     = 0,
    TriangleVertexInputIndexViewportSize = 1,
} TriangleVertexInputIndex;

//  This structure defines the layout of vertices sent to the vertex
//  shader. This header is shared between the .metal shader and C code, to guarantee that
//  the layout of the vertex array in the C code matches the layout that the .metal
//  vertex shader expects.
typedef struct
{
    vector_float2 position;
    vector_float4 color;
} TriangleVertex;

#endif /* MST_Triangle_h */
