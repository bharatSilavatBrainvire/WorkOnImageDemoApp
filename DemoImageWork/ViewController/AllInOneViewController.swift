//
//  AllInOneViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit
import CoreImage

class AllInOneViewController: UIViewController {
    
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var plusMinusLabelBackView: UIView!
    @IBOutlet weak var frameBoundFilterNamebackView: UIView!
    @IBOutlet weak var frameLabel: UILabel!
    @IBOutlet weak var boundLabel: UILabel!
    @IBOutlet weak var featureNameLabel: UILabel!
    @IBOutlet weak var layersButtonAction: UIButton!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var undoRedoSegmentControl: UISegmentedControl!
    
    //MARK: - Local variables -
    private let filters = ImageFilter.allCases
    private var originalImage: UIImage!
    private var currentSelectedFilter: ImageFilter?
    private var ciContext: CIContext!
    private var ciImage: CIImage!
    private var spotlightLayer: CAShapeLayer!
    private var spotlightFrame = CGRect(x: 100, y: 200, width: 150, height: 150)
    private var value: Float = 0.0 {
        didSet {
            updateValueLabel()
            if let selectedFilter = currentSelectedFilter {
                applyFilter(selectedFilter)
            }
        }
    }
    
    //MARK: - ViewDidLoad -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        satupGestures()
    }
    
    @IBAction func pickAnImage(_ sender: UIButton) {
        presentImagePicker()
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        resetAllFilter()
    }
    
    @IBAction func downLoadButtonAction(_ sender: UIButton) {
        guard let imageToSave = testImageView.image else {
            print("No image to save.")
            return
        }
        
        let renderer = UIGraphicsImageRenderer(bounds: imageContainerView.bounds)
        let flattenedImage = renderer.image { context in
            imageContainerView.layer.render(in: context.cgContext)
        }
        testImageView.image = flattenedImage
        UIImageWriteToSavedPhotosAlbum(flattenedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func minusButtonAction(_ sender: UIButton) {
        guard let filter = currentSelectedFilter, filter.isAdjustable else { return }
        value = max(filter.minValue, value - 0.1)
    }
    
    @IBAction func plusButtonAction(_ sender: UIButton) {
        guard let filter = currentSelectedFilter, filter.isAdjustable else { return }
        value = min(filter.maxValue, value + 0.1)
    }
    
    @IBAction func showAllLayersButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction func undoRedoAction(_ sender: UISegmentedControl) {
        debugPrint("UndoRedo Tapped")
    }
}

extension AllInOneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as? FilterCVCell else {
            return UICollectionViewCell()
        }
        
        let filter = filters[indexPath.item]
        cell.setupFilterCellUI(with: filter)
        return cell
    }
    
}

extension AllInOneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.item]
        self.currentSelectedFilter = selectedFilter
        
        value = selectedFilter.isAdjustable ? selectedFilter.defaultValue : 0.0
        updateValueLabel()
        updateFilterUI(for: selectedFilter)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}

//MARK: - Basic logical functionality -
extension AllInOneViewController {
    
    private func setupBasicUI() {
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        
        testImageView.isUserInteractionEnabled = true
        let buttonArray = [pickImageButton,resetButton,downloadButton,minusButton,plusButton,layersButtonAction]
        
        buttonArray.forEach { button in
            button?.layer.cornerRadius = 10
            button?.clipsToBounds = true
        }
        
        plusMinusLabelBackView.layer.cornerRadius = 10
        frameBoundFilterNamebackView.layer.cornerRadius = 10
        
        originalImage = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")!
        ciImage = CIImage(image: originalImage)!
        
        ciContext = CIContext()
        testImageView.image = originalImage
        
    }
    
    private func updateValueLabel() {
        currentValueLabel.text = String(format: "%.1f", value)
    }
    
    private func satupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        testImageView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        testImageView.addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        testImageView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        testImageView.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        testImageView.addGestureRecognizer(panGesture)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSpotlightPan(_:)))
        view.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleSpotlightPinch(_:)))
        view.addGestureRecognizer(pinch)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleSpotlightRotation(_:)))
        view.addGestureRecognizer(rotate)
        
    }
    
    private func setupHollowMask() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.isUserInteractionEnabled = false // Allow touches to pass through
        view.addSubview(overlay)

        spotlightLayer = CAShapeLayer()
        spotlightLayer.fillRule = .evenOdd
        overlay.layer.mask = spotlightLayer
        updateSpotlightMask()
    }
    
    private func updateSpotlightMask() {
        let path = UIBezierPath(rect: view.bounds)
        
        let shapeValue = (spotlightFrame.width == spotlightFrame.height) ? "circle" : "rectangle"
        
        if shapeValue == "circle" {
            path.append(UIBezierPath(ovalIn: spotlightFrame))
        } else {
            path.append(UIBezierPath(rect: spotlightFrame))
        }
        
        spotlightLayer.path = path.cgPath
    }


    
    private func applyFilter(_ filter: ImageFilter) {
        guard let baseImage = testImageView.image else { return }
        
        switch filter {
        case .rotateLeft:
            testImageView.image = baseImage.rotate(radians: -.pi / 2)
            return
        case .rotateRight:
            testImageView.image = baseImage.rotate(radians: .pi / 2)
            return
        case .flipHorizontal:
            testImageView.image = baseImage.flip(horizontal: true)
            return
        case .flipVertical:
            testImageView.image = baseImage.flip(horizontal: false)
            return
        case .crop:
            testImageView.image = cropCenterSquare(baseImage)
            return
        case .addSticker:
            addSticker(named: "drawing-tablet")
            return
        case .addFill, .addText:
            print("fill or text not implemented")
            return
        case .spotlight:
            return setupHollowMask()
        default:
            break
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciInputImage = CIImage(image: baseImage) else { return }
            
            var outputImage: CIImage?
            
            switch filter {
            case .brightness:
                let ciFilter = CIFilter(name: "CIColorControls")!
                ciFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
                ciFilter.setValue(self.value - 0.5, forKey: kCIInputBrightnessKey)
                outputImage = ciFilter.outputImage
                
            case .contrast:
                let ciFilter = CIFilter(name: "CIColorControls")!
                ciFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
                ciFilter.setValue(self.value * 2.0, forKey: kCIInputContrastKey)
                outputImage = ciFilter.outputImage
                
            case .saturation:
                let ciFilter = CIFilter(name: "CIColorControls")!
                ciFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
                ciFilter.setValue(self.value, forKey: kCIInputSaturationKey)
                outputImage = ciFilter.outputImage
                
            case .blur:
                let ciFilter = CIFilter(name: "CIGaussianBlur")!
                ciFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
                ciFilter.setValue(self.value, forKey: kCIInputRadiusKey)
                outputImage = ciFilter.outputImage
                
            case .sharpen:
                let ciFilter = CIFilter(name: "CISharpenLuminance")!
                ciFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
                ciFilter.setValue(self.value, forKey: kCIInputSharpnessKey)
                outputImage = ciFilter.outputImage
                
            default:
                return
            }
            
            guard let finalCIImage = outputImage,
                  let cgImage = CIContext().createCGImage(finalCIImage, from: finalCIImage.extent) else {
                return
            }
            
            let finalUIImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                self.testImageView.image = finalUIImage
            }
        }
    }
    
    
    private func resetAllFilter() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let newCIImage = CIImage(image: self.originalImage),
                  let cgImage = self.ciContext.createCGImage(newCIImage, from: newCIImage.extent) else {
                return
            }
            
            let filteredImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                self.testImageView.image = filteredImage
                self.plusMinusLabelBackView.isHidden = true
                self.frameBoundFilterNamebackView.isHidden = true
                self.testImageView.layoutIfNeeded()
                self.view.isUserInteractionEnabled = true
                
                self.spotlightFrame = CGRect(x: 100, y: 150, width: 200, height: 200)
                self.spotlightLayer.mask = nil
                self.spotlightLayer.isHidden = true
            }
            
            self.ciImage = newCIImage
            self.currentSelectedFilter = nil
        }
    }
    
    
    private func updateImageView(with ciImage: CIImage) {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error: Unable to create CGImage from CIImage")
            return
        }
        
        let filteredImage = UIImage(cgImage: cgImage)
        testImageView.image = filteredImage
    }
    
    private func updateFilterUI(for filter: ImageFilter) {
        DispatchQueue.main.async {
            if filter.isAdjustable {
                self.plusMinusLabelBackView.isHidden = false
                self.frameBoundFilterNamebackView.isHidden = true
            } else {
                self.plusMinusLabelBackView.isHidden = true
                self.frameBoundFilterNamebackView.isHidden = false
                self.featureNameLabel.text = filter.name
                self.frameLabel.text = "Frame: \(self.testImageView.frame)"
                self.boundLabel.text = "Bounds: \(self.testImageView.bounds)"
            }
        }
    }
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addSticker(named imageName: String) {
        print("addSticker called")
        guard let stickerImage = UIImage(named: imageName) else { return }
        
        let stickerImageView = UIImageView(image: stickerImage)
        stickerImageView.isUserInteractionEnabled = true
        stickerImageView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleStickerPinch(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleStickerRotate(_:)))
        
        stickerImageView.addGestureRecognizer(pan)
        stickerImageView.addGestureRecognizer(pinch)
        stickerImageView.addGestureRecognizer(rotate)
        self.imageContainerView.addSubview(stickerImageView)
    }
    
}

//MARK: - Objective C methods -
extension AllInOneViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            showAlert(title: "Save Failed", message: error.localizedDescription)
        } else {
            print("Image saved successfully.")
            showAlert(title: "Saved!", message: "Your edited image has been saved to your Photos.")
        }
    }
    
    // MARK: - Sticker Gesture Handlers
    @objc func handleStickerPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: self.view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: self.view)
        featureNameLabel.text = "Sticker Drag"
    }
    
    @objc func handleStickerPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
        featureNameLabel.text = "Sticker Pinch"
    }
    
    @objc func handleStickerRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        featureNameLabel.text = "Sticker Rotate"
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        featureNameLabel.text = "Tap"
        print("Single tap detected")
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        featureNameLabel.text = "Double Tap"
        print("Double tap detected")
        testImageView.transform = .identity
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
        featureNameLabel.text = "Pinch/Scal"
        
    }
    
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        featureNameLabel.text = "Rotation"
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view?.superview)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: gesture.view?.superview)
        featureNameLabel.text = "Pan / Drag"
    }
    
    @objc func handleSpotlightPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        spotlightFrame.origin.x += translation.x
        spotlightFrame.origin.y += translation.y
        
        gesture.setTranslation(.zero, in: view)
        
        updateSpotlightMask()
    }

    @objc func handleSpotlightPinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        
        spotlightFrame.size.width *= scale
        spotlightFrame.size.height *= scale
        
        gesture.scale = 1.0
        
        updateSpotlightMask()
    }

    @objc func handleSpotlightRotation(_ gesture: UIRotationGestureRecognizer) {
        let rotation = gesture.rotation
        
        spotlightFrame = spotlightFrame.applying(CGAffineTransform(rotationAngle: rotation))
        
        gesture.rotation = 0
        
        updateSpotlightMask()
    }
}

//MARK: - ImagePicker methods -
extension AllInOneViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            self.originalImage = selectedImage
            DispatchQueue.main.async {
                self.testImageView.image = selectedImage
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
