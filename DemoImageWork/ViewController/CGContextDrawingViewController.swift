//
//  CGContextDrawingViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class CGContextDrawingViewController: UIViewController {
    
    // Setup the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example 1: Basic Drawing View
        let basicDrawingView = BasicDrawingView(frame: self.view.bounds)
        basicDrawingView.backgroundColor = .lightGray
        self.view.addSubview(basicDrawingView)
        
        // Example 2: Gradient Drawing View (uncomment to use)
        // let gradientDrawingView = GradientDrawingView(frame: self.view.bounds)
        // gradientDrawingView.backgroundColor = .lightGray
        // self.view.addSubview(gradientDrawingView)
        
        // Example 3: Dashed Line Drawing View (uncomment to use)
        // let dashedLineDrawingView = DashedLineDrawingView(frame: self.view.bounds)
        // dashedLineDrawingView.backgroundColor = .lightGray
        // self.view.addSubview(dashedLineDrawingView)
        
        // Example 4: Image Drawing View (uncomment to use)
        // let imageDrawingView = ImageDrawingView(frame: self.view.bounds)
        // imageDrawingView.backgroundColor = .lightGray
        // self.view.addSubview(imageDrawingView)
        
        // Example 5: Rotated Shape Drawing View (uncomment to use)
        // let rotatedShapeView = RotatedShapeView(frame: self.view.bounds)
        // rotatedShapeView.backgroundColor = .lightGray
        // self.view.addSubview(rotatedShapeView)
        
        // Example 6: Circle with Stroke and Fill Drawing View (uncomment to use)
        // let circleDrawingView = CircleDrawingView(frame: self.view.bounds)
        // circleDrawingView.backgroundColor = .lightGray
        // self.view.addSubview(circleDrawingView)
        
        // Example 7: Text Drawing View (uncomment to use)
        // let textDrawingView = TextDrawingView(frame: self.view.bounds)
        // textDrawingView.backgroundColor = .lightGray
        // self.view.addSubview(textDrawingView)
    }
}


class BasicDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw a red rectangle
        context.setFillColor(UIColor.red.cgColor)
        let rectToDraw = CGRect(x: 50, y: 50, width: 200, height: 100)
        context.fill(rectToDraw)
        
        // Draw a blue circle
        context.setFillColor(UIColor.blue.cgColor)
        let circleRect = CGRect(x: 100, y: 200, width: 100, height: 100)
        context.fillEllipse(in: circleRect)
        
        // Draw a black line
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: 50, y: 350))
        context.addLine(to: CGPoint(x: 300, y: 350))
        context.strokePath()
    }
}

class TextDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw text in a custom font
        let text = "Hello, CGContext!"
        let font = UIFont.boldSystemFont(ofSize: 36)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: 50, y: 50, width: textSize.width, height: textSize.height)
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}

class CircleDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw a filled circle with stroke
        let circleRect = CGRect(x: 100, y: 100, width: 150, height: 150)
        
        // Fill the circle with red color
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: circleRect)
        
        // Stroke the circle with black color and width of 5
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(5)
        context.strokeEllipse(in: circleRect)
    }
}


class RotatedShapeView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Save the current graphics state
        context.saveGState()
        
        // Set up the rotation (rotate 45 degrees)
        context.translateBy(x: 150, y: 150) // Move the origin to the center
        context.rotate(by: .pi / 4) // Rotate 45 degrees
        
        // Draw a rotated rectangle
        context.setFillColor(UIColor.red.cgColor)
        let rotatedRect = CGRect(x: -50, y: -50, width: 100, height: 100) // Adjust coordinates after rotation
        context.fill(rotatedRect)
        
        // Restore the graphics state
        context.restoreGState()
    }
}



class ImageDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw an image
        if let image = UIImage(named: "exampleImage") {
            let imageRect = CGRect(x: 50, y: 50, width: 200, height: 200)
            image.draw(in: imageRect)
        }
    }
}

// MARK: - Example 3: Dashed Line
class DashedLineDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Set up the dashed line
        context.setLineWidth(5)
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineDash(phase: 0, lengths: [10, 5]) // Dash pattern: 10 pt on, 5 pt off
        
        // Draw a dashed line
        context.move(to: CGPoint(x: 50, y: 100))
        context.addLine(to: CGPoint(x: 300, y: 100))
        context.strokePath()
    }
}

class GradientDrawingView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Clear the background with white color
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Define the gradient
        let colors = [UIColor.red.cgColor, UIColor.blue.cgColor] // Gradient from red to blue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)
        
        // Define the start and end points for the gradient
        let startPoint = CGPoint(x: 50, y: 50)
        let endPoint = CGPoint(x: 250, y: 150)
        
        // Draw the gradient in a rectangle
        context.saveGState()
        context.addRect(CGRect(x: 50, y: 50, width: 200, height: 100))
        context.clip()
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
}
