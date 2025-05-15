//
//  ViewController.swift
//  Task1
//
//  Created by Bharat Shilavat on 14/05/25.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var testingImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var addStickerButton: UIButton!
    
    //MARK: - Local variables -
    private var originalImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIForScreen()
        setupGestures()
    }
    
    
    @IBAction func addImageOfStickerButtonAction(_ sender: UIButton) {
        if sender.tag == 2 {
            presentImagePicker()
        } else if sender.tag == 4 {
            addSticker(named: "think-different")
        } else if sender.tag == 6 {
            let renderer = UIGraphicsImageRenderer(bounds: imageContainerView.bounds)
            let flattenedImage = renderer.image { context in
                imageContainerView.layer.render(in: context.cgContext)
            }
            testingImageView.image = flattenedImage
            UIImageWriteToSavedPhotosAlbum(flattenedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            debugPrint("Remove Background button tapped")
            let outputImage = removeBackground(from: self.testingImageView.image!, backgroundColor: .white, deltaEThreshold: 15)
            self.testingImageView.image = outputImage
        }
    }
}

//MARK: - local methods -
extension ViewController {
    private func setupUIForScreen() {
        testingImageView.isUserInteractionEnabled = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addSticker(named imageName: String) {
        guard let stickerImage = UIImage(named: imageName) else { return }
        let stickerImageView = UIImageView(image: stickerImage)
        stickerImageView.isUserInteractionEnabled = true
        stickerImageView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        // --- Draw the rectangular outline with corner circles ---
        let outlineLayer = CAShapeLayer()
        outlineLayer.strokeColor = UIColor.blue.cgColor
        outlineLayer.fillColor = UIColor.clear.cgColor
        outlineLayer.lineWidth = 2
        stickerImageView.layer.addSublayer(outlineLayer) // Add to the sticker's layer
        
        let rectanglePath = UIBezierPath(rect: stickerImageView.bounds) // Use bounds for local coordinates
        outlineLayer.path = rectanglePath.cgPath
        
        // Define the corner points of the rectangle
        let topLeft = CGPoint(x: stickerImageView.bounds.minX, y: stickerImageView.bounds.minY)
        let topRight = CGPoint(x: stickerImageView.bounds.maxX, y: stickerImageView.bounds.minY)
        let bottomLeft = CGPoint(x: stickerImageView.bounds.minX, y: stickerImageView.bounds.maxY)
        let bottomRight = CGPoint(x: stickerImageView.bounds.maxX, y: stickerImageView.bounds.maxY)
        
        let cornerPoints = [topLeft, topRight, bottomRight, bottomLeft]
        let circleRadius: CGFloat = 6
        let circleStrokeColor = UIColor.green.cgColor
        let circleLineWidth: CGFloat = 2
        
        for center in cornerPoints {
            let circlePath = UIBezierPath(
                arcCenter: center,
                radius: circleRadius,
                startAngle: 0,
                endAngle: 2 * CGFloat.pi,
                clockwise: true
            )
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = circleStrokeColor
            circleLayer.lineWidth = circleLineWidth
            stickerImageView.layer.addSublayer(circleLayer) // Add each circle layer to the sticker's layer
        }
        
        let deleteStickerButton = UIButton(frame: CGRect(x: 4, y: 4, width: 20, height: 20))
        deleteStickerButton.setImage(UIImage(systemName: "xmark.bin.circle"), for: .normal)
        deleteStickerButton.addTarget(self, action: #selector(deleteSticker), for: .touchUpInside)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleStickerPinch(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleStickerRotate(_:)))
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleStickerLongPress(_:)))
        
        stickerImageView.addGestureRecognizer(pan)
        stickerImageView.addGestureRecognizer(pinch)
        stickerImageView.addGestureRecognizer(rotate)
        //stickerImageView.addGestureRecognizer(longPress)
        
        pinch.delegate = self
        pan.delegate = self
        rotate.delegate = self
        
        stickerImageView.addSubview(deleteStickerButton)
        self.testingImageView.addSubview(stickerImageView)
    }
    
    private func setupGestures() {
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        //        doubleTapGesture.numberOfTapsRequired = 2
        //        testingImageView.addGestureRecognizer(doubleTapGesture)
        //
        //        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        //        testingImageView.addGestureRecognizer(pinchGesture)
        //
        //        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        //        testingImageView.addGestureRecognizer(rotationGesture)
        //
        //        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        //        testingImageView.addGestureRecognizer(panGesture)
        //
        //        let longPressGesture = UILongPressGestureRecognizer(target: self, action:  #selector(handleLongPress(_:)))
        //        testingImageView.addGestureRecognizer(longPressGesture)
        
        
        //SRT - Scaling, Roatation, Translation -
    }
    
}

//MARK: - Objective c methods -
extension ViewController {
    @objc func handleStickerPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: self.view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: self.view)
        
        // Calculate current scale from transform
        let currentScaleX = sqrt(view.transform.a * view.transform.a + view.transform.c * view.transform.c)
        
        // Adjust border width to visually stay the same
        if let imageView = view as? UIImageView {
            let originalBorderWidth: CGFloat = 2
            imageView.layer.borderWidth = originalBorderWidth / currentScaleX
        }
        
    }
    
    @objc func handleStickerPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    @objc func handleStickerRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        // Rotate the sticker
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        
        // Keep the delete button upright
        if let deleteButton = view.subviews.first(where: { $0 is UIButton }) {
            let angle = atan2(view.transform.b, view.transform.a)
            debugPrint("Angle before rotation -> \(angle)")
            deleteButton.transform = CGAffineTransform(rotationAngle: -angle)
        }
    }
    
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        print("Double tap detected")
        testingImageView.transform = .identity
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view?.superview)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: gesture.view?.superview)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("Long press gusture captured")
    }
    
    @objc func handleStickerLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("Remove sticker pressed")
    }
    
    //Saving image -
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            showAlert(title: "Save Failed", message: error.localizedDescription)
        } else {
            print("Image saved successfully.")
            showAlert(title: "Saved!", message: "Your edited image has been saved to your Photos.")
        }
    }
    
    @objc func deleteSticker(_ sender: UIButton) {
        
    }
    
}

//MARK: - Image Picker Controller -
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func presentImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            // imagePickerController.allowsEditing = true
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Photo Library is not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        //        if let croppedImage = info[.editedImage] as? UIImage {
        //            selectedImage = croppedImage
        //        } else
        if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            self.originalImage = image
            DispatchQueue.main.async {
                self.testingImageView.image = image
            }
            
            //            if let compressedData = image.jpegData(compressionQuality: 0.5) {
            //                let sizeInMB = Double(compressedData.count) / (1024.0 * 1024.0)
            //                print(String(format: "Compressed image size: %.2f MB", sizeInMB))
            //            } else {
            //                print("Failed to compress image.")
            //            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Gestures Recognizer Delegate Methods -
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController {
    func removeBackground(from image: UIImage, backgroundColor: UIColor, deltaEThreshold: Double = 10.0) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let pixelBuffer = context.data else { return nil }
        
        let buffer = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var rBg: CGFloat = 0, gBg: CGFloat = 0, bBg: CGFloat = 0, aBg: CGFloat = 0
        backgroundColor.getRed(&rBg, green: &gBg, blue: &bBg, alpha: &aBg)
        let labBackground = rgbToLAB(r: rBg, g: gBg, b: bBg)
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = CGFloat(buffer[offset]) / 255.0
                let g = CGFloat(buffer[offset + 1]) / 255.0
                let b = CGFloat(buffer[offset + 2]) / 255.0
                
                let labPixel = rgbToLAB(r: r, g: g, b: b)
                let dE = deltaE(labPixel, labBackground)
                
                if dE < deltaEThreshold {
                    buffer[offset + 3] = 0 // Make transparent
                }
            }
        }
        
        guard let resultCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: resultCGImage)
    }
}

