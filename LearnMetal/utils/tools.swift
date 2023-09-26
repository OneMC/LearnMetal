//
//  tools.swift
//  LearnMetal
//
//  Created by ONEMC on 2023/9/18.
//

import Foundation

typealias ShaderFuncs = (vertex: MTLFunction, fragment: MTLFunction)

func shaderFuncs(_ vertexName: String, _ fragmentName: String, _ device: MTLDevice) -> ShaderFuncs {
    let bundle = Bundle.init(for: AppDelegate.self)
    guard let url = bundle.url(forResource: "default", withExtension: "metallib"),
          let library = try? device.makeLibrary(URL: url),
          let vertexFunc = library.makeFunction(name: vertexName),
          let fragmentFunc = library.makeFunction(name: fragmentName)
    else {
        fatalError(#function)
    }
    
    return (vertexFunc, fragmentFunc)
}
