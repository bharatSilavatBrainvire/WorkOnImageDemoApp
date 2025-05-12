//
//  EdgeDetectionViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit
import CoreImage

class EdgeDetectionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var originalImage: UIImage!
    var ciContext: CIContext!
    var edgeCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Load image and context
        originalImage = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")!
        ciContext = CIContext()

        // Setup imageView
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // IMPORTANT!
        
        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)

        // Setup edge count label
        edgeCountLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.maxY - 100, width: view.frame.width - 40, height: 60))
        edgeCountLabel.numberOfLines = 2
        edgeCountLabel.textAlignment = .center
        edgeCountLabel.textColor = .black
        view.addSubview(edgeCountLabel)

        applyEdgeDetection()
    }

    func applyEdgeDetection() {
        guard let ciImage = CIImage(image: originalImage),
              let filter = CIFilter(name: "CIEdges") else { return }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(10.0, forKey: kCIInputIntensityKey)

        guard let outputImage = filter.outputImage,
              let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)
        imageView.image = uiImage

        // Analyze the image to estimate edge count
        estimateEdgeCount(from: cgImage)
    }

    func estimateEdgeCount(from cgImage: CGImage) {
        guard let data = cgImage.dataProvider?.data else { return }
        let ptr = CFDataGetBytePtr(data)

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let width = cgImage.width
        let height = cgImage.height

        var edgePixelCount = 0
        let brightnessThreshold: UInt8 = 100

        for y in 0..<height {
            for x in 0..<width {
                let index = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let r = ptr?[index] ?? 0
                let g = ptr?[index + 1] ?? 0
                let b = ptr?[index + 2] ?? 0

                let brightness = (UInt16(r) + UInt16(g) + UInt16(b)) / 3
                if brightness > brightnessThreshold {
                    edgePixelCount += 1
                }
            }
        }

        let totalPixels = width * height
        let edgePercentage = (Double(edgePixelCount) / Double(totalPixels)) * 100
        let edgeStrength = edgePercentage > 10 ? "High" : "Low"

        edgeCountLabel.text = "Edges Found: \(edgePixelCount)\nEdge Strength: \(edgeStrength)"
    }

    // MARK: - Pinch Gesture Handler
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1.0 // Reset scale for incremental updates
    }
}
