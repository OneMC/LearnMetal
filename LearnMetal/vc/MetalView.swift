//
//  MetalView.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/8/21.
//

import UIKit
import MetalKit

class MetalView: UIView {
    let mtkView: MTKView
    var render: Render
    
    init(_ render: Render) {
        self.render = render
        mtkView = MTKView()
        mtkView.isPaused = true
        mtkView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        super.init(frame: CGRectZero)
        addMetalView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRender() {
        render.view = mtkView
        render.setupPipeline()
        mtkView.isPaused = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mtkView.frame = bounds
    }
}

private extension MetalView {
    func addMetalView() {
        guard let device = MTLCreateSystemDefaultDevice()
        else {
            fatalError("Metal is not supported on this device")
        }
        mtkView.device = device
        mtkView.delegate = self
        addSubview(mtkView)
    }
}

extension MetalView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        render.size = size
    }
    
    func draw(in view: MTKView) {
        render.renderInView(view)
    }
}
