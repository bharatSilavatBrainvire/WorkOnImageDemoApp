//
//  Renderer.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import Foundation
import MetalKit


//class Renderer : NSObject {
//    //Create MTLDevice - Step 1
//    let device: MTLDevice
//    //Create Command Queue - Step 2
//    let commandQueue: MTLCommandQueue
//    //create verices - Step 3
//    let vertices : [Float] = [0, 0, 0, -1, -1, 0, 1, -1, 0 ]
//    //Create PipeLine - Step 4
//    var pipeLineState: MTLRenderPipelineState?
//    //Create vertex Buffer - Step 5
//    var vertexBuffer: MTLBuffer?
//    
//    
//    
//    init(device: MTLDevice) {
//        self.device = device
//        commandQueue = device.makeCommandQueue()!
//        super.init()
//        buildModel()
//    }
//    
//    private func buildModel() {
//        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
//    }
//    
//}
//
//extension Renderer : MTKViewDelegate {
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        
//    }
//    
//    func draw(in view: MTKView) {
//        guard let view = view.currentDrawable,
//              let descripter = view.currentRenderPassDescriptor else {return}
//    }
//    
//    
//}
