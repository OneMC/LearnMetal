//
//  Render.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/8/21.
//

import Foundation
import MetalKit

// https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
// https://developer.apple.com/documentation/metal/metal_sample_code_library

protocol Render {
    var commandQueue: MTLCommandQueue? { get }
    var pipeLineState: MTLRenderPipelineState? { get }
    var view: MTKView? { get set }
    var size: CGSize { get set }
    func setupPipeline();
    func renderInView(_ view: MTKView);
}
