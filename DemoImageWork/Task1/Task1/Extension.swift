//
//  Extension.swift
//  Task1
//
//  Created by Bharat Shilavat on 14/05/25.
//

import Foundation
import CoreImage
import UIKit

struct LAB {
    let l: Double
    let a: Double
    let b: Double
}

func rgbToLAB(r: CGFloat, g: CGFloat, b: CGFloat) -> LAB {
    func pivot(_ n: CGFloat) -> CGFloat {
        return (n > 0.04045) ? pow((n + 0.055) / 1.055, 2.4) : n / 12.92
    }

    // sRGB → XYZ
    let R = pivot(r)
    let G = pivot(g)
    let B = pivot(b)

    let x = (R * 0.4124 + G * 0.3576 + B * 0.1805) / 0.95047
    let y = (R * 0.2126 + G * 0.7152 + B * 0.0722) / 1.00000
    let z = (R * 0.0193 + G * 0.1192 + B * 0.9505) / 1.08883

    func f(_ t: CGFloat) -> CGFloat {
        return (t > pow(6.0/29.0, 3.0)) ? pow(t, 1.0/3.0) : (1.0/3.0) * pow(29.0/6.0, 2.0) * t + 4.0/29.0
    }

    let L = 116.0 * f(y) - 16.0
    let A = 500.0 * (f(x) - f(y))
    let M = 200.0 * (f(y) - f(z))

    return LAB(l: Double(L), a: Double(A), b: Double(M))
}

func deltaE(_ lab1: LAB, _ lab2: LAB) -> Double {
    let dl = lab1.l - lab2.l
    let da = lab1.a - lab2.a
    let db = lab1.b - lab2.b
    return sqrt(dl * dl + da * da + db * db)
}
