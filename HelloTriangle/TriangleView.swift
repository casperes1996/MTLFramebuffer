//
//  TriangleView.swift
//  HelloTriangle
//
//  Created by Casper Sørensen on 12/07/2021.
//

import Cocoa
import MetalKit

class TriangleView: MTKView, CAMetalDisplayLinkDelegate {
    func metalDisplayLink(_ link: CAMetalDisplayLink, needsUpdate update: CAMetalDisplayLink.Update) {
        let descriptor = MTLRenderPassDescriptor()
        _ = update.drawable
        descriptor.colorAttachments[0].texture = update.drawable.texture
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].loadAction = .clear
        
        let cmdBuff = cmdQueue?.makeCommandBuffer()
        let cmdEncoder = cmdBuff?.makeRenderCommandEncoder(descriptor: descriptor)
    
        descriptor.colorAttachments[0].clearColor = .init(red: 1, green: 0.2, blue: 1, alpha: 1)
    
        cmdEncoder?.setRenderPipelineState(rps)
        
        cmdEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        systemTime = systemTime.advanced(by: 0.01)
        let currentFrame = [Float(systemTime-firstFrame)]

        let fragBuf = device?.makeBuffer(bytes: currentFrame, length: MemoryLayout<Float>.stride, options: [.hazardTrackingModeUntracked, .storageModeManaged, .cpuCacheModeWriteCombined])
        cmdEncoder?.setFragmentBuffer(fragBuf, offset: 0, index: 1)
        
        cmdEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        cmdEncoder?.drawPrimitives(type: .triangle, vertexStart: 1, vertexCount: 3)
        cmdEncoder?.endEncoding()
        cmdBuff?.present(update.drawable)
        cmdBuff?.commit()
    }
    
    
    struct Vertex {
        var position: SIMD4<Float>
        var color: SIMD4<Float>
    }
    
    var cmdQueue: MTLCommandQueue?
    
    var systemTime = NSTimeIntervalSince1970

    var firstFrame = NSTimeIntervalSince1970
    
    var vertices: [Vertex]
    
    var rps: MTLRenderPipelineState!

    
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    var vertexBuffer: MTLBuffer!

    required init(coder: NSCoder) {
        vertices = TriangleView.makeVertices()
            
        super.init(coder: coder)
        
        colorPixelFormat = .bgr10a2Unorm
        clearColor = .init(red: 0.9, green: 0.2, blue: 0.9, alpha: 1)
        device = preferredDevice
        (layer as! CAMetalLayer).device = device
        cmdQueue = device?.makeCommandQueue()
        vertexBuffer = device?.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride*vertices.count, options: []                 )
        makeRenderPipelineDescriptor()
        try! rps =  device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        isPaused = true
        enableSetNeedsDisplay = true
        
        let link = CAMetalDisplayLink(metalLayer: layer as! CAMetalLayer)
        link.delegate = self
        link.preferredFrameRateRange = .init(minimum: 48, maximum: 160, __preferred: 160)
        link.add(to: .current, forMode: .default)
    }
    
    func makeRenderPipelineDescriptor() {
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgr10a2Unorm
        let lib = device?.makeDefaultLibrary()
        let vertexShader = lib?.makeFunction(name: "vertex_shader")
        let fragmentShader = lib?.makeFunction(name: "fragment_shader")
        renderPipelineDescriptor.vertexFunction = vertexShader
        renderPipelineDescriptor.fragmentFunction = fragmentShader
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    static func makeVertices() -> [Vertex] {
        return [Vertex(position: [-1,1,0,1], color: [0,0,0,1]),
                Vertex(position: [1, 1, 0,1], color: [1,0,0,1]),
                Vertex(position: [-1,-1,0,1], color: [0,1,0,1]),
                Vertex(position: [1,-1,0,1], color: [0,0,1,1]),
                ]
    }
}
