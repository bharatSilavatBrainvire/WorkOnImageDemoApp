//
//  MetalKitBlendingVC.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//

import UIKit
import Metal
import MetalKit

class MetalKitBlendingVC: UIViewController {

    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var ciContext: CIContext!
    var textureLoader: MTKTextureLoader!
    @IBOutlet weak var testingBackView: UIView!
    var metalView: MTKView!
    var texture: MTLTexture?
    var brushTexture: MTLTexture?
    var pipelineState: MTLRenderPipelineState?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        loadImageTexture()
        setupBrushTexture()
        setupPipeline()
        addPanGesture()
    }

    private func setupMetal() {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal is not supported on this device.")
            return
        }

        device = defaultDevice
        commandQueue = device?.makeCommandQueue()
        guard let device = device else {
            print("❌ Metal device is not available.")
            return
        }

        ciContext = CIContext(mtlDevice: device)
        textureLoader = MTKTextureLoader(device: device)

        // Initialize and configure metalView
        metalView = MTKView(frame: testingBackView.bounds, device: device)
        metalView.framebufferOnly = false
        metalView.delegate = self
        metalView.contentMode = .scaleAspectFit
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.translatesAutoresizingMaskIntoConstraints = false

        // Add metalView to the testingBackView
        testingBackView.addSubview(metalView)

        // Ensure metalView resizes with testingBackView
        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(equalTo: testingBackView.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: testingBackView.bottomAnchor),
            metalView.leadingAnchor.constraint(equalTo: testingBackView.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: testingBackView.trailingAnchor)
        ])
    }



    private func loadImageTexture() {
        guard let image = UIImage(named: "pexels-stephan-ernst-2151845602-31884207") else {
            print("⚠️ Image not found. Check the name and asset catalog.")
            return
        }

        guard let ciImage = CIImage(image: image) else {
            print("⚠️ Could not create CIImage from UIImage.")
            return
        }

        texture = createTexture(from: ciImage)
    }

    private func createTexture(from ciImage: CIImage) -> MTLTexture? {
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]

        guard let texture = device?.makeTexture(descriptor: descriptor) else {
            print("❌ Failed to create Metal texture.")
            return nil
        }

        ciContext.render(ciImage, to: texture, commandBuffer: nil, bounds: ciImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        return texture
    }

    private func setupBrushTexture() {
        let size = 64
        let color = UIColor(white: 1.0, alpha: 1.0)
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        guard let context = UIGraphicsGetCurrentContext() else {
            print("⚠️ Could not get current graphics context.")
            return
        }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let brushImage = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = brushImage.cgImage else {
            print("⚠️ Could not get CGImage from brush context.")
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()

        do {
            brushTexture = try textureLoader.newTexture(cgImage: cgImage, options: nil)
        } catch {
            print("❌ Failed to create brush texture: \(error.localizedDescription)")
        }
    }

    private func setupPipeline() {
        guard let defaultLibrary = device?.makeDefaultLibrary(),
              let vertexFunction = defaultLibrary.makeFunction(name: "vertex_main"),
              let fragmentFunction = defaultLibrary.makeFunction(name: "fragment_erase") else {
            print("❌ Failed to load Metal shader functions.")
            return
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("❌ Failed to create pipeline state: \(error.localizedDescription)")
        }
    }

    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: metalView)
        let scale = metalView.drawableSize.width / metalView.bounds.width
        let x = point.x * scale
        let y = (metalView.bounds.height - point.y) * scale
        drawBrush(at: CGPoint(x: x, y: y))
    }

    private func drawBrush(at point: CGPoint) {
        guard let drawable = metalView.currentDrawable,
              let pipelineState = pipelineState,
              let texture = texture,
              let brushTexture = brushTexture else {
            print("⚠️ Missing drawable, pipelineState or texture resources.")
            return
        }

        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let descriptor = metalView.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("⚠️ Failed to create command buffer or render encoder.")
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setFragmentTexture(brushTexture, index: 1)

        var position = vector_float2(Float(point.x), Float(point.y))
        renderEncoder.setFragmentBytes(&position, length: MemoryLayout<vector_float2>.size, index: 0)

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension MetalKitBlendingVC: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let texture = texture,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let ciImage = CIImage(mtlTexture: texture, options: nil) else {
            print("⚠️ draw() skipped due to missing drawable, texture, or command buffer.")
            return
        }

        // Scale CIImage to fit drawable size
        let targetSize = view.drawableSize
        let scaleX = targetSize.width / ciImage.extent.width
        let scaleY = targetSize.height / ciImage.extent.height
        let scale = min(scaleX, scaleY)

        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Center the image
        let xOffset = (targetSize.width - scaledImage.extent.width) / 2
        let yOffset = (targetSize.height - scaledImage.extent.height) / 2
        let translatedImage = scaledImage.transformed(by: CGAffineTransform(translationX: xOffset, y: yOffset))

        ciContext.render(translatedImage,
                         to: drawable.texture,
                         commandBuffer: commandBuffer,
                         bounds: CGRect(origin: .zero, size: targetSize),
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
