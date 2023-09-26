//
//  TextureRender.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/9/13.
//

import Foundation
import MetalKit

// https://developer.apple.com/documentation/metal/textures/creating_and_sampling_textures

private func V(_ posi:(Float, Float),  _ color:(Float,Float)) -> BasicTexVertex {
    BasicTexVertex(position: vector_float2(x: posi.0, y: posi.1),
                   textureCoordinate: vector_float2(x: color.0, y: color.1))
}

class TexutreRender: Render {
    var commandQueue: MTLCommandQueue? = nil
    var pipeLineState: MTLRenderPipelineState? = nil
    weak var view: MTKView?
    var size: CGSize = CGSizeZero
    
    private var vertices: MTLBuffer? = nil
    private var texture: MTLTexture? = nil
    
    private let quadVertices: [BasicTexVertex] = [V(( 250, -250), (1.0, 1.0)),
                                          V((-250, -250), (0.0, 1.0)),
                                          V((-250,  250), (0.0, 0.0)),
                                          
                                          V(( 250, -250), (1.0, 1.0)),
                                          V((-250,  250), (0.0, 0.0)),
                                          V(( 250,  250), (1.0, 0.0))]
    func setupPipeline() {
        guard let view = view,
              let device = view.device
        else {
            fatalError(#function)
        }
      
        let shaderFunc = shaderFuncs("tex_vertexShader", "tex_samplingShader", device)
        let pipeLineDesc = MTLRenderPipelineDescriptor()
        pipeLineDesc.label = String(describing: Self.self) + "Render"
        pipeLineDesc.vertexFunction = shaderFunc.vertex
        pipeLineDesc.fragmentFunction = shaderFunc.fragment
        pipeLineDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        do {
            pipeLineState = try device.makeRenderPipelineState(descriptor: pipeLineDesc)
            commandQueue = device.makeCommandQueue()
        } catch  {
            fatalError(#function)
        }
        
        vertices = device.makeBuffer(bytes: quadVertices,
                                     length: MemoryLayout<BasicTexVertex>.stride*quadVertices.count,
                                     options: .storageModeShared)
        
        guard let url = Bundle.main.url(forResource: "Image", withExtension: "tga") else {
            fatalError("load image error")
        }
        texture = loadTextureFromImage(url:url)
    }
    
    func renderInView(_ view: MTKView) {
        guard let commandQueue = commandQueue,
              let pipeLineState = pipeLineState,
              let currentDraw = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDesc = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)
        else {
            fatalError(#function)
        }
        
        renderEncoder.label = "textureEncoder"
        renderEncoder.setRenderPipelineState(pipeLineState)
        let viewport = MTLViewport(originX: 0.0, originY: 0.0,
                                   width: size.width, height: size.height,
                                   znear: 0.0, zfar: 1.0)
        renderEncoder.setViewport(viewport)
        var viewportSiz = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        renderEncoder.setVertexBuffer(vertices, offset: 0, index: Int(BasicTexVertexInputIndexVertices.rawValue))
        renderEncoder.setVertexBytes(&viewportSiz, length: MemoryLayout.size(ofValue: viewport), index: Int(BasicTexVertexInputIndexViewportSize.rawValue))
        renderEncoder.setFragmentTexture(texture, index: Int(BasicTexTextureIndexBaseColor.rawValue))
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: quadVertices.count)
        renderEncoder.endEncoding()
        
        commandBuffer.present(currentDraw)
        commandBuffer.commit()
    }
}

private extension TexutreRender {
    func loadTextureFromImage(url: URL) -> MTLTexture? {
        guard let device = view?.device,
              let image = AAPLImage(tgaFileAtLocation: url)
        else {
            fatalError("Failed to create the image from \(url.absoluteString)")
        }
        
        let imagePointer: UnsafeRawPointer? = image.data.withUnsafeBytes { $0.baseAddress }
        guard let imagePointer = imagePointer else {
            fatalError(#function)
        }
        
        let textureDescriptor = MTLTextureDescriptor()

        // Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is
        // an 8-bit unsigned normalized value (i.e. 0 maps to 0.0 and 255 maps to 1.0)
        textureDescriptor.pixelFormat = .bgra8Unorm

        // Set the pixel dimensions of the texture
        textureDescriptor.width = Int(image.width)
        textureDescriptor.height = Int(image.height)

        // Create the texture from the device by using the descriptor
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Failed to create the texture \(url.absoluteString)")
        }

        // Calculate the number of bytes per row in the image.
        let bytesPerRow = 4 * image.width
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: Int(image.width), height: Int(image.height), depth: 1))
    
        // Copy the bytes from the data object into the texture
        texture.replace(region: region, mipmapLevel: 0, withBytes: imagePointer, bytesPerRow: Int(bytesPerRow))
        return texture
    }
}
