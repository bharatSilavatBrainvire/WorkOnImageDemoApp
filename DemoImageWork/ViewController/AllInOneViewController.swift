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
    
    
    //MARK: - Local variables -
    private let filters = ImageFilter.allCases
    private var originalImage: UIImage!
    private var currentSelectedFilter: ImageFilter?
    private var ciContext: CIContext!
    private var ciImage: CIImage!
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
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func minusButtonAction(_ sender: UIButton) {
        guard let filter = currentSelectedFilter, filter.isAdjustable else { return }
        value = max(filter.minValue, value - 0.1)
    }
    
    @IBAction func plusButtonAction(_ sender: UIButton) {
        guard let filter = currentSelectedFilter, filter.isAdjustable else { return }
        value = min(filter.maxValue, value + 0.1)
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
        applyFilter(selectedFilter)
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
        let buttonArray = [pickImageButton,resetButton,downloadButton,minusButton,plusButton]
        
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
    
    private func applyFilter(_ filter: ImageFilter) {
        guard let originalImage = originalImage else { return }
        
        var outputImage: CIImage?
        
        switch filter {
        case .brightness:
            let ciFilter = CIFilter(name: "CIColorControls")!
            ciFilter.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            ciFilter.setValue(value - 0.5, forKey: kCIInputBrightnessKey)
            outputImage = ciFilter.outputImage
            
        case .contrast:
            let ciFilter = CIFilter(name: "CIColorControls")!
            ciFilter.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            ciFilter.setValue(value * 2.0, forKey: kCIInputContrastKey)
            outputImage = ciFilter.outputImage
            
        case .saturation:
            let ciFilter = CIFilter(name: "CIColorControls")!
            ciFilter.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            ciFilter.setValue(value, forKey: kCIInputSaturationKey)
            outputImage = ciFilter.outputImage
            
        case .blur:
            let ciFilter = CIFilter(name: "CIGaussianBlur")!
            ciFilter.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            ciFilter.setValue(value, forKey: kCIInputRadiusKey)
            outputImage = ciFilter.outputImage
            
        case .sharpen:
            let ciFilter = CIFilter(name: "CISharpenLuminance")!
            ciFilter.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            ciFilter.setValue(value, forKey: kCIInputSharpnessKey)
            outputImage = ciFilter.outputImage
            
        case .rotateLeft:
            testImageView.image = testImageView.image?.rotate(radians: -.pi / 2)
            return
            
        case .rotateRight:
            testImageView.image = testImageView.image?.rotate(radians: .pi / 2)
            return
            
        case .flipHorizontal:
            testImageView.image = testImageView.image?.flip(horizontal: true)
            return
            
        case .flipVertical:
            testImageView.image = testImageView.image?.flip(horizontal: false)
            return
            
        case .crop:
            testImageView.image = cropCenterSquare(testImageView.image ?? originalImage)
            return
        }
        
        if let finalCIImage = outputImage,
           let cgImage = CIContext().createCGImage(finalCIImage, from: finalCIImage.extent) {
            let finalUIImage = UIImage(cgImage: cgImage)
            self.testImageView.image = finalUIImage
        }
    }
    
    private func resetAllFilter() {
        ciImage = CIImage(image: originalImage)!
        updateImageView(with: ciImage)
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
        if filter.isAdjustable {
            plusMinusLabelBackView.isHidden = false
            frameBoundFilterNamebackView.isHidden = true
        } else {
            plusMinusLabelBackView.isHidden = true
            frameBoundFilterNamebackView.isHidden = false
            
            featureNameLabel.text = filter.name
            frameLabel.text = "Frame: \(testImageView.frame)"
            boundLabel.text = "Bounds: \(testImageView.bounds)"
        }
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
            self.testImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Objective C function -
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
