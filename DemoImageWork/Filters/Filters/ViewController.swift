//
//  ViewController.swift
//  Filters
//
//  Created by Bharat Shilavat on 15/05/25.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let context = CIContext()
    var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = UIImage(named: "CheckImage")
        imageView.image = originalImage
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func applyFilter(name: String) {
        print("Applying filter: \(name)")
        
        guard let image = originalImage,
              let cgImage = image.cgImage,
              let filterType = FilterType(rawValue: name) else {
            print("❌ Invalid image or filter name.")
            return
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let extent = ciImage.extent
        
        guard let filter = CIFilter(name: filterType.rawValue) else {
            print("❌ CIFilter not found for \(name)")
            return
        }
        
        filter.setDefaults()
        
        switch filterType {
        case .additionCompositing, .blendWithAlphaMask, .blendWithMask, .colorBlendMode,
                .colorBurnBlendMode, .darkenBlendMode, .differenceBlendMode, .exclusionBlendMode,
                .hardLightBlendMode, .hueBlendMode, .lightenBlendMode, .linearBurnBlendMode,
                .linearDodgeBlendMode, .softLightBlendMode, .sourceAtopCompositing,
                .sourceInCompositing, .sourceOutCompositing, .sourceOverCompositing, .subtractBlendMode:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
            
        case .affineClamp, .affineTile:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CGAffineTransform(scaleX: 1.0, y: 1.0), forKey: kCIInputTransformKey)

            if let outputImage = filter.outputImage {
                let cropRect = outputImage.extent.intersection(extent)
                if cropRect.isEmpty {
                    print("❌ Crop rect is empty")
                    return
                }
                let croppedImage = outputImage.cropped(to: cropRect)
                if let cgImage = context.createCGImage(croppedImage, from: cropRect) {
                    let filteredImage = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        self.imageView.image = filteredImage
                    }
                } else {
                    print("❌ Failed to create CGImage for affineClamp/Tile")
                }
            } else {
                print("❌ Filter outputImage is nil for affineClamp/Tile")
            }

        case .areaAverage, .areaHistogram, .areaMaximum, .areaMaximumAlpha,
                .areaMinimum, .areaMinimumAlpha:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgRect: ciImage.extent), forKey: "inputExtent")
            if filter.inputKeys.contains("inputCount") {
                filter.setValue(64, forKey: "inputCount")
            }
            if filter.inputKeys.contains("inputScale") {
                filter.setValue(1.0, forKey: "inputScale")
            }
            
        case .bloom:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            filter.setValue(10.0, forKey: kCIInputRadiusKey)
            
        case .boxBlur, .discBlur, .gaussianBlur:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(5.0, forKey: kCIInputRadiusKey)
            
        case .bumpDistortion:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: extent.midX, y: extent.midY), forKey: kCIInputCenterKey)
            filter.setValue(150.0, forKey: kCIInputRadiusKey)
            filter.setValue(0.5, forKey: kCIInputScaleKey)
            
        case .circleSplashDistortion:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            let centerVector = CIVector(x: extent.midX, y: extent.midY)
            filter.setValue(centerVector, forKey: kCIInputCenterKey)
            filter.setValue(150.0, forKey: kCIInputRadiusKey)

            if let outputImage = filter.outputImage?.cropped(to: extent),
               let cgImage = context.createCGImage(outputImage, from: extent) {
                let filteredImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.imageView.image = filteredImage
                }
            } else {
                print("❌ Failed to create CGImage for CICircleSplashDistortion")
            }

            
        case .pinchDistortion:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: extent.midX, y: extent.midY), forKey: kCIInputCenterKey)
            filter.setValue(150.0, forKey: kCIInputRadiusKey)
            filter.setValue(0.5, forKey: kCIInputScaleKey)
            
        case .vortexDistortion:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: extent.midX, y: extent.midY), forKey: kCIInputCenterKey)
            filter.setValue(150.0, forKey: kCIInputRadiusKey)
            filter.setValue(2.0, forKey: kCIInputAngleKey)
            
        case .colorControls:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(0.8, forKey: kCIInputSaturationKey)
            filter.setValue(0.8, forKey: kCIInputBrightnessKey)
            filter.setValue(1.2, forKey: kCIInputContrastKey)
            
        case .colorCube:
            print("⚠️ Color cube not implemented (requires 3D data)")
            return
            
        case .colorInvert, .photoEffectChrome, .photoEffectFade, .photoEffectInstant,
                .photoEffectMono, .photoEffectNoir, .photoEffectProcess,
                .photoEffectTonal, .photoEffectTransfer:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
        case .colorMap:
            let gradient = CIFilter(name: "CILinearGradient")!
            gradient.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
            gradient.setValue(CIColor.red, forKey: "inputColor0")
            gradient.setValue(CIVector(x: extent.width, y: extent.height), forKey: "inputPoint1")
            gradient.setValue(CIColor.blue, forKey: "inputColor1")
            
            if let gradientImage = gradient.outputImage?.cropped(to: extent) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(gradientImage, forKey: "inputGradientImage")
                
                if let outputCIImage = filter.outputImage?.cropped(to: extent),
                   let outputCGImage = context.createCGImage(outputCIImage, from: extent) {
                    let filteredImage = UIImage(cgImage: outputCGImage)
                    DispatchQueue.main.async {
                        self.imageView.image = filteredImage
                    }
                } else {
                    print("❌ Failed to create CGImage from colorMap output")
                }
            } else {
                print("❌ Failed to create gradient image for CIColorMap")
            }
            
        case .colorMatrix:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
            filter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
            filter.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
            filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
            
        case .colorMonochrome:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: kCIInputColorKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            
        case .convolution3X3, .convolution5X5, .convolution9Horizontal, .convolution9Vertical:
            print("⚠️ Convolution filters need matrix weights. Skipped.")
            return
            
        case .crop:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgRect: extent.insetBy(dx: 20, dy: 20)), forKey: "inputRectangle")
            
        case .dissolveTransition:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(ciImage, forKey: "inputTargetImage")
            filter.setValue(0.5, forKey: kCIInputTimeKey)
            
        case .dotScreen:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: extent.midX, y: extent.midY), forKey: kCIInputCenterKey)
            filter.setValue(6.0, forKey: kCIInputAngleKey)
            filter.setValue(2.0, forKey: kCIInputWidthKey)
            filter.setValue(0.7, forKey: kCIInputSharpnessKey)
            
        case .edges:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            
        case .exposureAdjust:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputEVKey)
            
        case .falseColor:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor.red, forKey: "inputColor0")
            filter.setValue(CIColor.blue, forKey: "inputColor1")
            
        case .gammaAdjust:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(0.75, forKey: "inputPower")
            
        case .gloom:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            filter.setValue(10.0, forKey: kCIInputRadiusKey)
            
        case .hueAdjust:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(Float.pi / 2, forKey: kCIInputAngleKey)
            
        case .linearGradient:
            let gradient = CIFilter(name: "CILinearGradient")!
            gradient.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
            gradient.setValue(CIColor.red, forKey: "inputColor0")
            gradient.setValue(CIVector(x: extent.width, y: extent.height), forKey: "inputPoint1")
            gradient.setValue(CIColor.blue, forKey: "inputColor1")
            
            guard let gradientImage = gradient.outputImage?.cropped(to: extent) else {
                print("❌ Failed to create gradient image for CILinearGradient")
                return
            }
            
            // Composite the gradient over the original image
            let compositeFilter = CIFilter(name: "CISourceOverCompositing")!
            compositeFilter.setValue(gradientImage, forKey: kCIInputImageKey)      // top image (gradient)
            compositeFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey) // bottom image (original)
            
            if let outputImage = compositeFilter.outputImage?.cropped(to: extent),
               let cgImage = context.createCGImage(outputImage, from: extent) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: cgImage)
                }
            } else {
                print("❌ Failed to create CGImage from composited image")
            }

        case .pixellate:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(10.0, forKey: kCIInputScaleKey)
            
        case .redEyeReduction:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue([CIVector(x: extent.midX, y: extent.midY)], forKey: "inputEyePositions")
            print("This is skipped by apple mean deprected")
        case .sepiaTone:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            
        case .sharpenLuminance:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(0.5, forKey: kCIInputSharpnessKey)
            
        case .straightenFilter:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(Float.pi / 8, forKey: kCIInputAngleKey)
            
        case .temperatureAndTint:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            filter.setValue(CIVector(x: 8000, y: 0), forKey: "inputTargetNeutral")
            
        case .toneCurve:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
            filter.setValue(CIVector(x: 0.25, y: 0.25), forKey: "inputPoint1")
            filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
            filter.setValue(CIVector(x: 0.75, y: 0.75), forKey: "inputPoint3")
            filter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")
            
        case .unsharpMask:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(2.5, forKey: kCIInputRadiusKey)
            filter.setValue(0.5, forKey: kCIInputIntensityKey)
            
        case .vibrance:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: "inputAmount")
            
        case .whitePointAdjust:
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor.white, forKey: kCIInputColorKey)
        }
        
        // Render
        guard let outputCIImage = filter.outputImage else {
            print("❌ outputImage is nil")
            return
        }
        
        if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            let filteredImage = UIImage(cgImage: outputCGImage)
            DispatchQueue.main.async {
                self.imageView.image = filteredImage
            }
        } else {
            print("❌ Failed to create CGImage")
        }
    }
    
    
    
    // MARK: - UICollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Your cell setup here — e.g. show filter name
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        
        cell.label.text  = FilterType.allCases[indexPath.item].rawValue
        cell.layer.borderColor = UIColor.random().cgColor
        cell.layer.borderWidth = 1.5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilterName = FilterType.allCases[indexPath.item].rawValue
        applyFilter(name: selectedFilterName)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 186, height: 50)
    }
}


extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
