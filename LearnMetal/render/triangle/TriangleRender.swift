//
//  TriangleRender.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/9/1.
//

import Foundation
import MetalKit

// https://developer.apple.com/documentation/metal/using_a_render_pipeline_to_render_primitives

private func V(posi:(Float, Float),  color:(Float,Float,Float,Float)) -> TriangleVertex {
    TriangleVertex(position: vector_float2(x: posi.0, y: posi.1),
                   color: vector_float4(x: color.0, y: color.1, z: color.2, w: color.3))
}

typealias TriVertexConfig = (vertices: [TriangleVertex], funcName: String)

private let vertexClipSpace: [TriangleVertex] = [
    V(posi: ( 0.5, -0.5), color: (1, 0, 0, 1)),
    V(posi: (-0.5, -0.5), color: (0, 1, 0, 1)),
    V(posi: ( 0,    0),   color: (0, 0, 1, 1))
]

private let vertexPixelSpace: [TriangleVertex] = [
    V(posi: ( 250, -250), color: (1, 0, 0, 1)),
    V(posi: (-250, -250), color: (0, 1, 0, 1)),
    V(posi: ( 0,    250), color: (0, 0, 1, 1))
]

let clipSpaceConfig: TriVertexConfig = (vertexClipSpace, "tri_clip_vertexShader")
let pixelSpaceConfig: TriVertexConfig = (vertexPixelSpace, "tri_pixel_vertexShader")

class TriangleRender: Render {
    let vertexConfig: TriVertexConfig
    
    var commandQueue: MTLCommandQueue? = nil
    var pipeLineState: MTLRenderPipelineState? = nil
    weak var view: MTKView? = nil
    var size: CGSize = CGSizeZero
    
    init(_ vertexConfig: TriVertexConfig) {
        self.vertexConfig = vertexConfig
    }
    
    func setupPipeline() {
        guard let view = view,
              let device = view.device
        else {
            fatalError(#function)
        }
        
        let shaderFunc = shaderFuncs(vertexConfig.funcName, "triangle_fragmentShader", device)
        let pipeLineDesc = MTLRenderPipelineDescriptor()
        pipeLineDesc.label = String(describing: Self.self) + "Render"
        pipeLineDesc.vertexFunction = shaderFunc.vertex
        pipeLineDesc.fragmentFunction = shaderFunc.fragment
        pipeLineDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        do {
            pipeLineState = try device.makeRenderPipelineState(descriptor: pipeLineDesc)
            commandQueue = device.makeCommandQueue()
        } catch  {
            assert(false, error.localizedDescription)
        }
        
    }
    
    func renderInView(_ view: MTKView) {
        guard let commandQueue = commandQueue,
              let pipeLineState = pipeLineState,
              let currentDraw = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDesc = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)
        else {
            assert(false, #function)
            return
        }
        renderEncoder.label = "triangleEncoder"
        renderEncoder.setRenderPipelineState(pipeLineState)
        
        let viewport = MTLViewport(originX: 0.0, originY: 0.0,
                                   width: size.width, height: size.height,
                                   znear: 0.0, zfar: 1.0)
        renderEncoder.setViewport(viewport)
        
        let vertices = self.vertexConfig.vertices
        renderEncoder.setVertexBytes(vertices,
                                     length: MemoryLayout<TriangleVertex>.stride * vertices.count,
                                     index: Int(TriangleVertexInputIndexVertices.rawValue))
        
        var viewportSiz = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        renderEncoder.setVertexBytes(&viewportSiz,
                                     length: MemoryLayout<vector_uint2>.size,
                                     index:1)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(currentDraw)
        commandBuffer.commit()
        
        assert(commandBuffer.error == nil, "draw error：\(String(describing: commandBuffer.error?.localizedDescription))")
    }
}
