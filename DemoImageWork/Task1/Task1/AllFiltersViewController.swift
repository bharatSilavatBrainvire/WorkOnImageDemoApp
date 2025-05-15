//
//  AllFiltersViewController.swift
//  Task1
//
//  Created by Bharat Shilavat on 15/05/25.
//

import UIKit

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class AllFiltersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let context = CIContext()
    let filterNames: [String] = [
        "CIAdditionCompositing", "CIAffineClamp", "CIAffineTile", "CIAreaAverage",
        "CIAreaHistogram", "CIAreaMaximum", "CIAreaMaximumAlpha", "CIAreaMinimum",
        "CIAreaMinimumAlpha", "CIBlendWithAlphaMask", "CIBlendWithMask", "CIBloom",
        "CIBoxBlur", "CIBumpDistortion", "CICircleSplashDistortion", "CIColorBlendMode",
        "CIColorBurnBlendMode", "CIColorControls", "CIColorCube", "CIColorInvert",
        "CIColorMap", "CIColorMatrix", "CIColorMonochrome", "CIConvolution3X3",
        "CIConvolution5X5", "CIConvolution9Horizontal", "CIConvolution9Vertical",
        "CICrop", "CIDarkenBlendMode", "CIDifferenceBlendMode", "CIDiscBlur",
        "CIDissolveTransition", "CIDotScreen", "CIEdges", "CIExclusionBlendMode",
        "CIExposureAdjust", "CIFalseColor", "CIGaussianBlur", "CIGammaAdjust",
        "CIGloom", "CIHardLightBlendMode", "CIHueAdjust", "CIHueBlendMode",
        "CILightenBlendMode", "CILinearBurnBlendMode", "CILinearDodgeBlendMode",
        "CILinearGradient", "CIPhotoEffectChrome", "CIPhotoEffectFade",
        "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir",
        "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer",
        "CIPinchDistortion", "CIPixellate", "CIRedEyeReduction", "CISepiaTone",
        "CISharpenLuminance", "CISoftLightBlendMode", "CISourceAtopCompositing",
        "CISourceInCompositing", "CISourceOutCompositing", "CISourceOverCompositing",
        "CIStraightenFilter", "CISubtractBlendMode", "CITemperatureAndTint",
        "CIToneCurve", "CIUnsharpMask", "CIVibrance", "CIVortexDistortion",
        "CIWhitePointAdjust"
    ]
    
    var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = UIImage(named: "imagetest") // add your image to Assets.xcassets
        imageView.image = originalImage
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func applyFilter(name: String) {
        guard let image = originalImage,
              let cgImage = image.cgImage else { return }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: name) else {
            print("Filter \(name) not found")
            return
        }

        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        // Apply only if outputImage is available
        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.label.text = filterNames[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filterNames[indexPath.row]
        applyFilter(name: selectedFilter)
    }
}


  
