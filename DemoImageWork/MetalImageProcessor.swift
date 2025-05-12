//
//  MetalImageProcessor.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 09/05/25.
//

import Foundation
import Metal
import MetalKit
import UIKit


class MetalImageProcessor {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private let pipeline: MTLRenderPipelineState

    init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary()
        else {
            return nil
        }

        self.device = device
        self.commandQueue = commandQueue
        self.library = library

        // Create a pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        // Load the vertex and fragment functions from the Metal library
        if let vertexFunction = library.makeFunction(name: "vertex_passthrough"),
           let fragmentFunction = library.makeFunction(name: "imageShader") {
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
        } else {
            print("----> Failed to load vertex or fragment functions from the Metal library.")
            return nil
        }

        // Set the color attachment pixel format (BGRA format for image processing)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // Create and configure the vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()

        // Setup position attribute (attribute index 0)
        vertexDescriptor.attributes[0].format = .float4  // position is a float4
        vertexDescriptor.attributes[0].offset = 0        // Position starts at offset 0
        vertexDescriptor.attributes[0].bufferIndex = 0   // Comes from the first buffer

        // Setup texCoord attribute (attribute index 1)
        vertexDescriptor.attributes[1].format = .float2  // texCoord is a float2
        vertexDescriptor.attributes[1].offset = 16       // texCoord starts after the position (size of float4 = 16 bytes)
        vertexDescriptor.attributes[1].bufferIndex = 0   // Comes from the first buffer

        // Setup the layout for the vertex buffer (stride)
        vertexDescriptor.layouts[0].stride = 24  // Each vertex contains 16 bytes for position and 8 bytes for texCoord (float4 + float2)

        // Attach the vertex descriptor to the pipeline descriptor
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
            // Create the render pipeline state
            self.pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("----> Failed to create pipeline: \(error)")
            return nil
        }
    }

    func process(image: UIImage,
                 brightness: Float,
                 contrast: Float,
                 saturation: Float,
                 exposure: Float,
                 temperature: Float) -> UIImage? {

        var brightness = brightness
        var contrast = contrast
        var saturation = saturation
        var exposure = exposure
        var temperature = temperature

        guard let cgImage = image.cgImage else {
            print("----> Failed to get cgImage from UIImage")
            return nil
        }

        // Convert UIImage to MTLTexture with correct usage flags
        let textureLoader = MTKTextureLoader(device: device)
        let textureOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .SRGB: false
        ]

        var mtlTexture: MTLTexture!
        do {
            mtlTexture = try textureLoader.newTexture(cgImage: cgImage, options: textureOptions)
        } catch {
            print("----> Error loading texture: \(error)")
            return nil
        }

        if mtlTexture == nil {
            print("----> Failed to create MTLTexture.")
            return nil
        }

        // Set texture descriptor with pixel format matching the pipeline's expectation
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .bgra8Unorm  // Match the pipeline's expected format
        textureDescriptor.width = mtlTexture.width
        textureDescriptor.height = mtlTexture.height
        textureDescriptor.usage = [.renderTarget, .shaderRead]

        guard let newMtlTexture = device.makeTexture(descriptor: textureDescriptor) else {
            print("----> Failed to create new MTLTexture with updated descriptor.")
            return nil
        }

        // Setup the command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("----> Failed to create command buffer.")
            return nil
        }

        // Set up the render pass descriptor with matching format
        let passDescriptor = MTLRenderPassDescriptor()
        let colorAttachment = passDescriptor.colorAttachments[0]
        
        colorAttachment?.texture = newMtlTexture
        colorAttachment?.loadAction = .clear  // Use .load if you want to preserve the previous texture
        colorAttachment?.clearColor = MTLClearColorMake(0, 0, 0, 1)
        colorAttachment?.storeAction = .store

        if colorAttachment?.texture == nil {
            print("----> Pass descriptor texture is nil.")
            return nil
        }

        // Create the render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            print("----> Failed to create render command encoder.")
            return nil
        }

        // Apply shader and set buffers (adjust brightness, contrast, etc.)
        renderEncoder.setRenderPipelineState(pipeline)

        renderEncoder.setFragmentBytes(&brightness, length: MemoryLayout<Float>.size, index: 0)
        renderEncoder.setFragmentBytes(&contrast, length: MemoryLayout<Float>.size, index: 1)
        renderEncoder.setFragmentBytes(&saturation, length: MemoryLayout<Float>.size, index: 2)
        renderEncoder.setFragmentBytes(&exposure, length: MemoryLayout<Float>.size, index: 3)
        renderEncoder.setFragmentBytes(&temperature, length: MemoryLayout<Float>.size, index: 4)

        // Bind the texture to the shader
        renderEncoder.setFragmentTexture(mtlTexture, index: 0)

        // Draw the texture
        renderEncoder.endEncoding()

        // Commit the command buffer and wait for completion
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Convert the processed MTLTexture back to UIImage
        let ciImage = CIImage(mtlTexture: newMtlTexture)
        let context = CIContext()
        if let changedImage = ciImage {
            if let cgImage = context.createCGImage(changedImage, from: changedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        } else {
            print("----> changedImage is nil")
        }

        print("----> Returning original old image without changes")
        return image
    }
}
