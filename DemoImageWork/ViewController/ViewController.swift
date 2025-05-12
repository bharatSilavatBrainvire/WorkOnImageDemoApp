//
//  ViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 09/05/25.
//

import UIKit
import MetalKit
import UIKit
import Foundation

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var slider5: UISlider!
    
    var originalImage: UIImage!
    var ciContext: CIContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ciContext = CIContext()
        imageImageView.isUserInteractionEnabled = true
        loadImage()
        
        // 🎛️ Configure sliders with proper ranges and defaults
        slider1.minimumValue = 0.0  // Brightness (mapped to -0.5 to +0.5)
        slider1.maximumValue = 1.0
        slider1.value = 0.5
        
        slider2.minimumValue = 0.5 // Contrast (mapped to ~1.0 to 3.0)
        slider2.maximumValue = 1.5
        slider2.value = 1.0
        
        slider3.minimumValue = 0.0 // Saturation
        slider3.maximumValue = 2.0
        slider3.value = 1.0
        
        slider4.minimumValue = -2.0 // Exposure EV
        slider4.maximumValue = 2.0
        slider4.value = 0.0
        
        slider5.minimumValue = -1.0 // Temperature shift (-1000K to +1000K)
        slider5.maximumValue = 1.0
        slider5.value = 0.0
    }
    
    func loadImage() {
        // Load your image here
        if let image = UIImage(named: "") {
            originalImage = image
            imageImageView.image = image
        }
    }
    
    
    
    @IBAction func changeImageButtonAction(_ sender: Any) {
        presentImagePicker()
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func sliderValueChangeAction(_ sender: UISlider) {
        print("sliderValueChangeAction Slider -> \(sender.tag)")
        switch sender.tag {
            case 101:
                print("Brightness slider moved: \(sender.value)")
            case 102:
                print("Contrast slider moved: \(sender.value)")
            case 103:
                print("Saturation slider moved: \(sender.value)")
            case 104:
                print("Exposure slider moved: \(sender.value)")
            case 105:
                print("Temperature slider moved: \(sender.value)")
            default:
                break
            }
            
            // 🛠️ Always apply all filters using all slider values
            applyFilters()
        
    }
    
    func applyFilters() {
        guard let originalImage = originalImage else { return }
        guard let inputCIImage = CIImage(image: originalImage) else { return }

        // 🎛️ Apply brightness, contrast, saturation together
        let colorControlsFilter = CIFilter(name: "CIColorControls")!
        colorControlsFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        colorControlsFilter.setValue(slider1.value - 0.5, forKey: kCIInputBrightnessKey) // Brightness
        colorControlsFilter.setValue(slider2.value * 2.0, forKey: kCIInputContrastKey)   // Contrast
        colorControlsFilter.setValue(slider3.value, forKey: kCIInputSaturationKey)      // Saturation

        var filteredImage = colorControlsFilter.outputImage

        // 💡 Apply exposure
        if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
            exposureFilter.setValue(filteredImage, forKey: kCIInputImageKey)
            exposureFilter.setValue(slider4.value, forKey: kCIInputEVKey)
            filteredImage = exposureFilter.outputImage
        }

        // 🌡️ Apply temperature
        if let temperatureFilter = CIFilter(name: "CITemperatureAndTint") {
            temperatureFilter.setValue(filteredImage, forKey: kCIInputImageKey)
            let neutralValue = CIVector(x: CGFloat(6500 + slider5.value * 1000), y: 0)
            temperatureFilter.setValue(neutralValue, forKey: "inputNeutral")
            filteredImage = temperatureFilter.outputImage
        }

        // 🔄 Convert and display
        if let finalImage = filteredImage,
           let cgImage = ciContext.createCGImage(finalImage, from: finalImage.extent) {
            DispatchQueue.main.async {
                self.imageImageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func presentImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Photo Library is not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            self.originalImage = selectedImage
            self.imageImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
