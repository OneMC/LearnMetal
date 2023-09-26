//
//  MST_BasicTexture.h
//  LearnMetal
//
//  Created by ONEMC on 2023/9/13.
//

#ifndef MST_BasicTexture_h
#define MST_BasicTexture_h

#include <simd/simd.h>

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum BasicTexVertexInputIndex
{
    BasicTexVertexInputIndexVertices     = 0,
    BasicTexVertexInputIndexViewportSize = 1,
} BasicTexVertexInputIndex;

// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API texture set calls
typedef enum BasicTexTextureIndex
{
    BasicTexTextureIndexBaseColor = 0,
} BasicTexTextureIndex;

//  This structure defines the layout of each vertex in the array of vertices set as an input to the
//    Metal vertex shader.  Since this header is shared between the .metal shader and C code,
//    you can be sure that the layout of the vertex array in the code matches the layout that
//    the vertex shader expects

typedef struct
{
    // Positions in pixel space. A value of 100 indicates 100 pixels from the origin/center.
    vector_float2 position;

    // 2D texture coordinate
    vector_float2 textureCoordinate;
} BasicTexVertex;

#endif /* MST_BasicTexture_h */
