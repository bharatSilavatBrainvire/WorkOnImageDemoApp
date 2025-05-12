//
//  AllEnums.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import Foundation
import UIKit

enum ImageFilter: CaseIterable {
    case crop
    case rotateLeft
    case rotateRight
    case flipHorizontal
    case flipVertical
    case brightness
    case contrast
    case saturation
    case blur
    case sharpen

    var name: String {
        switch self {
        case .crop: return "Crop"
        case .rotateLeft: return "Rotate Left"
        case .rotateRight: return "Rotate Right"
        case .flipHorizontal: return "Flip Horizontal"
        case .flipVertical: return "Flip Vertical"
        case .brightness: return "Brightness"
        case .contrast: return "Contrast"
        case .saturation: return "Saturation"
        case .blur: return "Blur"
        case .sharpen: return "Sharpen"
        }
    }

    var systemImageName: String {
        switch self {
        case .crop: return "crop"
        case .rotateLeft: return "rotate.left"
        case .rotateRight: return "rotate.right"
        case .flipHorizontal: return "flip.horizontal"
        case .flipVertical: return "flip.horizontal"
        case .brightness: return "sun.max"
        case .contrast: return "circle.lefthalf.filled"
        case .saturation: return "drop"
        case .blur: return "drop.halffull"
        case .sharpen: return "wand.and.stars"
        }
    }

    var minValue: Float {
        switch self {
        case .brightness: return 0.0
        case .contrast: return 0.5
        case .saturation: return 0.0
        case .blur: return 0.0
        case .sharpen: return 0.0
        default: return 0.0 
        }
    }

    var maxValue: Float {
        switch self {
        case .brightness: return 1.0
        case .contrast: return 1.5
        case .saturation: return 2.0
        case .blur: return 5.0
        case .sharpen: return 2.0
        default: return 0.0
        }
    }

    var defaultValue: Float {
        switch self {
        case .brightness: return 0.5
        case .contrast: return 1.0
        case .saturation: return 1.0
        case .blur: return 0.0
        case .sharpen: return 0.0
        default: return 0.0
        }
    }

    var isAdjustable: Bool {
        switch self {
        case .brightness, .contrast, .saturation, .blur, .sharpen:
            return true
        default:
            return false
        }
    }
}
