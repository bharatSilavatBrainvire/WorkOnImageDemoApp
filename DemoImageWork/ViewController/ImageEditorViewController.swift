//
//  ImageEditorViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//


import UIKit
import CoreImage

class ImageEditorViewController: UIViewController {
    
    // MARK: - UI Elements -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var vignetteButton: UIButton!
    @IBOutlet weak var transformButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var overlayButton: UIButton!
    
    var ciContext: CIContext!
    var ciImage: CIImage!
    var originalImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the original image
        originalImage = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")!
        ciImage = CIImage(image: originalImage)!
        
        // Initialize CIContext for processing
        ciContext = CIContext()
        
        // Setup the UI components
        setupUI()
    }
    
    func setupUI() {
        // Image View to display the image
        imageView.image = originalImage
        
        // Crop Button
        cropButton.setTitle("Crop Image", for: .normal)
        cropButton.backgroundColor = .white
        
        // Vignette Button
        vignetteButton.setTitle("Add Vignette", for: .normal)
        vignetteButton.backgroundColor = .systemGreen
        
        // Transform Button
        transformButton.setTitle("Transform Image", for: .normal)
        transformButton.backgroundColor = .systemOrange
        
        // Reset Button
        resetButton.setTitle("Reset Image", for: .normal)
        resetButton.backgroundColor = .systemRed
        
        overlayButton.setTitle("Apply Overlay", for: .normal)
        overlayButton.backgroundColor = .systemPurple
    }
    
    // MARK: - Image Editing Methods
    
    // Crop Image method
    @IBAction func cropImage() {
        // Define the crop area as a CGRect (x, y, width, height)
        let cropRect = CGRect(x: 50, y: 50, width: 200, height: 200)
        
        // Crop the image using Core Image
        let croppedImage = ciImage.cropped(to: cropRect)
        
        // Ensure the cropped image is rendered correctly and update the image view
        updateImageView(with: croppedImage)
    }
    
    
    // Vignette method
    @IBAction func applyVignette() {
        let filter = CIFilter(name: "CIVignette")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(2.0, forKey: kCIInputIntensityKey)
        filter.setValue(100.0, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return }
        updateImageView(with: outputImage)
    }
    
    // Transform Image method (Translation)
    @IBAction func transformImage() {
        // Print the extent of the original CIImage (before transformation)
        print("Original CIImage extent: \(ciImage.extent)")
        
        // Apply a translation transform (moving the image 100pts to the right, 50pts up)
        let transform = CGAffineTransform(translationX: 100, y: 50)
        let transformedImage = ciImage.transformed(by: transform)
        
        // Print the extent of the transformed CIImage
        print("Transformed CIImage extent: \(transformedImage.extent)")
        
        // Update the image view with the transformed image
        updateImageView(with: transformedImage)
    }
    
    
    // Reset the image to the original
    @IBAction func resetImage() {
        ciImage = CIImage(image: originalImage)!
        updateImageView(with: ciImage)
    }
    
    // Helper method to update the UIImageView with the processed image
    func updateImageView(with ciImage: CIImage) {
        // Create a CGImage with the correct color space from the CIImage
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error: Unable to create CGImage from CIImage")
            return
        }
        
        // Convert CGImage to UIImage
        let filteredImage = UIImage(cgImage: cgImage)
        
        // Update the image view with the processed image
        imageView.image = filteredImage
    }
    
    // MARK: - Compositing (Overlay Image) Example
    // MARK: - Overlay Action Method
    @IBAction func applyOverlay() {
        // Load the overlay image (this can be any UIImage)
        guard let overlayUIImage = UIImage(named: "think-different") else {
            print("Error: Overlay image not found.")
            return
        }
        let overlayCIImage = CIImage(image: overlayUIImage)!

        // Apply the overlay with a transform (position the overlay image)
        let transform = CGAffineTransform(translationX: 100, y: 100) // Position the overlay
        let transformedOverlay = overlayCIImage.transformed(by: transform)

        // Compositing the overlay image on top of the base image
        let compositingFilter = CIFilter(name: "CISourceOverCompositing")!
        compositingFilter.setValue(transformedOverlay, forKey: kCIInputImageKey)
        compositingFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

        // Get the composited image and update the image view
        guard let outputImage = compositingFilter.outputImage else {
            print("Error: Unable to create composited image.")
            return
        }
        
        // Update the image view with the composited image
        updateImageView(with: outputImage)
    }
}
