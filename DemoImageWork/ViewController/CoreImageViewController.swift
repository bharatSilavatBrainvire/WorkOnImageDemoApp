//
//  CoreImageViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit
import CoreImage

class CoreImageViewController: UIViewController {
    
    // MARK: - UI Elements
    var imageView: UIImageView!
    var applyFilterButton: UIButton!
    var filterSegmentControl: UISegmentedControl!
    
    var originalImage: UIImage!
    var ciContext: CIContext!
    var ciImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the original image
        originalImage = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")
        ciImage = CIImage(image: originalImage)!
        
        // Initialize CIContext for processing
        ciContext = CIContext()

        // Setup the UI components
        setupUI()
    }
    
    func setupUI() {
        // Image View to display the image
        imageView = UIImageView(frame: CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 300))
        imageView.contentMode = .scaleAspectFit
        imageView.image = originalImage
        self.view.addSubview(imageView)
        
        // Filter Selection Segment Control
        filterSegmentControl = UISegmentedControl(items: ["Sepia", "Vignette", "Gaussian Blur", "Invert", "Monochrome"])
        filterSegmentControl.frame = CGRect(x: 20, y: 420, width: self.view.frame.width - 40, height: 30)
        filterSegmentControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegmentControl.selectedSegmentIndex = 0
        self.view.addSubview(filterSegmentControl)
        
        // Apply Filter Button
        applyFilterButton = UIButton(frame: CGRect(x: 20, y: 470, width: self.view.frame.width - 40, height: 50))
        applyFilterButton.setTitle("Apply Filter", for: .normal)
        applyFilterButton.backgroundColor = .systemBlue
        applyFilterButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
        self.view.addSubview(applyFilterButton)
        
        let saveButton = UIButton(frame: CGRect(x: 20, y: 530, width: self.view.frame.width - 40, height: 50))
        saveButton.setTitle("Save Image", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        self.view.addSubview(saveButton)
        
    }
    
    // MARK: - Filter Methods
    
    @objc func filterChanged() {
        applyFilter()
    }
    
    @objc func applyFilter() {
        let selectedFilterIndex = filterSegmentControl.selectedSegmentIndex
        var filterName: String?
        
        // Choose the filter based on the selected segment
        switch selectedFilterIndex {
        case 0:
            filterName = "CISepiaTone"
        case 1:
            filterName = "CIVignette"
        case 2:
            filterName = "CIGaussianBlur"
        case 3:
            filterName = "CIColorInvert"
        case 4:
            filterName = "CIPhotoEffectMono"
        default:
            return
        }
        
        guard let filterName = filterName else { return }
        
        // Apply the filter
        applyCoreImageFilter(named: filterName)
    }
    
    @objc func saveImage() {
        guard let imageToSave = imageView.image else {
            print("No image to save.")
            return
        }

        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // Completion selector to handle result
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Show error message
            print("Error saving image: \(error.localizedDescription)")
            showAlert(title: "Save Failed", message: error.localizedDescription)
        } else {
            // Show success message
            print("Image saved successfully.")
            showAlert(title: "Saved!", message: "Your edited image has been saved to your Photos.")
        }
    }

    // Utility to show alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    func applyCoreImageFilter(named filterName: String) {
        // Create the filter
        guard let filter = CIFilter(name: filterName) else { return }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Apply filter-specific settings if needed
        if filterName == "CISepiaTone" {
            filter.setValue(0.8, forKey: kCIInputIntensityKey) // Intensity of Sepia
        }
        
        if filterName == "CIVignette" {
            filter.setValue(2.0, forKey: kCIInputIntensityKey) // Intensity of Vignette
            filter.setValue(30.0, forKey: kCIInputRadiusKey) // Radius of Vignette
        }
        
        if filterName == "CIGaussianBlur" {
            filter.setValue(5.0, forKey: kCIInputRadiusKey) // Blur radius
        }
        
        if filterName == "CIColorInvert" {
            // No additional values are required for invert
        }
        
        if filterName == "CIPhotoEffectMono" {
            // No additional values for this effect
        }
        
        // Get the output image and render it to UIImage
        guard let outputCIImage = filter.outputImage else { return }
        if let cgImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) {
            let filteredImage = UIImage(cgImage: cgImage)
            imageView.image = filteredImage
        }
    }
}
