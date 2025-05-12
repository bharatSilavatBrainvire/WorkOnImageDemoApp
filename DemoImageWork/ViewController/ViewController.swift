//
//  ViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 09/05/25.
//

import UIKit
import Metal
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
    
    var metalProcessor: MetalImageProcessor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalProcessor = MetalImageProcessor()
        imageImageView.isUserInteractionEnabled = true

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        imageImageView.addGestureRecognizer(pinchGesture)
    }
    
    
    @IBAction func changeImageButtonAction(_ sender: Any) {
        presentImagePicker()
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func sliderValueChangeAction(_ sender: UISlider) {
        print("sliderValueChangeAction Slider -> \(sender.tag)")
        
        guard let originalImage = imageImageView.image else { return }
        
        // Create variables to store the values from all sliders
        var brightness: Float = 0.0
        var contrast: Float = 1.0
        var saturation: Float = 1.0
        var exposure: Float = 1.0
        var temperature: Float = 0.0
        
        // Use slider tags to identify which slider was moved and adjust the properties accordingly
        switch sender.tag {
        case 101:
            brightness = sender.value - 0.5
            debugPrint("brightness -> \(brightness)")
        case 1022:
            contrast = sender.value * 2.0 // Adjust contrast (slider range [0, 2])
            debugPrint("contrast -> \(contrast)")
        case 103:
            saturation = sender.value // Adjust saturation (slider range [0, 1])
            debugPrint("saturation -> \(saturation)")
        case 104:
            exposure = sender.value // Adjust exposure (slider range [0, 2])
            debugPrint("exposure -> \(exposure)")
        case 105:
            temperature = sender.value // Adjust temperature (slider range [-1, 1])
            debugPrint("temperature -> \(temperature)")
        default:
            break
        }
        
        // Run Metal processing on a background thread to avoid blocking the main UI thread
        DispatchQueue.global(qos: .userInitiated).async {
            // Debug: Print the slider values to ensure they are being passed correctly
            debugPrint("----> brightness -> \(brightness), contrast -> \(contrast), saturation -> \(saturation), exposure -> \(exposure), temperature -> \(temperature)")
            
            if let output = self.metalProcessor?.process(image: originalImage,
                                                         brightness: brightness,
                                                         contrast: contrast,
                                                         saturation: saturation,
                                                         exposure: exposure,
                                                         temperature: temperature) {
                
                // Debug: Check if the output is valid
                debugPrint("----> Output image processed: \(String(describing: output))")
                
                // Once processing is done, update the UI on the main thread
                DispatchQueue.main.async {
                    
                    self.imageImageView.image = output
                    
                }
            } else {
                debugPrint("----> Image processing failed.")
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
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
