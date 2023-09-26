//
//  ViewController.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/8/21.
//

import UIKit

func vcForRenders() -> UIViewController {
    ViewController([
        TexutreRender(),
        TriangleRender(clipSpaceConfig),
        TriangleRender(pixelSpaceConfig)])
}

class ViewController: UIViewController {
    let scrollView = UIScrollView()
    let renders: [Render]
    init(_ renders: [Render]) {
        self.renders = renders
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 235, green: 235, blue: 235, alpha: 1.0)
        view.addSubview(scrollView)
        createMetalView(renders)
    }
    
    private func createMetalView(_ renders: [Render]) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        scrollView.contentSize = CGSize(width: width, height: width * CGFloat(renders.count))
        for i in renders.indices {
            let metalView = MetalView(renders[i])
            metalView.frame = CGRect(x: 0, y: (width+10)*CGFloat(i), width: width, height: width)
            scrollView.addSubview(metalView)
            metalView.setupRender()
        }
    }
}
