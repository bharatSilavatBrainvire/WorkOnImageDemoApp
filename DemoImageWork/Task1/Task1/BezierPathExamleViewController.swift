//
//  BezierPathExamleViewController.swift
//  Task1
//
//  Created by Bharat Shilavat on 15/05/25.
//

import UIKit


class BezierPathExamleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //drawSquareWithCornerCircles()
        drawLine()
    }
    
    
    func drawLine() {
        // 1. Create a UIBezierPath
        let squareSize: CGFloat = 200
        let x = (view.bounds.width - squareSize) / 2
        let y = (view.bounds.height - squareSize) / 2
        let squareRect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
        let path = UIBezierPath(rect: squareRect)
        
        // 2. Move to the starting point
        path.move(to: CGPoint(x: 50, y: 100))
        
        
        // 3. Add a line to the end point
        path.addLine(to: CGPoint(x: 250, y: 100))
        
        // 4. Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor // No fill for a line
        
        // 5. Add the layer to the view
        view.layer.addSublayer(shapeLayer)
    }
    
    
    func drawSquareWithCornerCircles() {
        let squareSize: CGFloat = 200
        let x = (view.bounds.width - squareSize) / 2
        let y = (view.bounds.height - squareSize) / 2
        let squareRect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
        let cornerRadius: CGFloat = 10 // Radius of the corner circles

        // 1. Create the bezier path for the square
        let squarePath = UIBezierPath(rect: squareRect)

        // 2. Create a shape layer for the square
        let squareLayer = CAShapeLayer()
        squareLayer.path = squarePath.cgPath
        squareLayer.strokeColor = UIColor.black.cgColor
        squareLayer.fillColor = UIColor.clear.cgColor
        squareLayer.lineWidth = 2
        view.layer.addSublayer(squareLayer)

        // Define the corner points of the square
        let topLeft = CGPoint(x: squareRect.minX, y: squareRect.minY)
        let topRight = CGPoint(x: squareRect.maxX, y: squareRect.minY)
        let bottomLeft = CGPoint(x: squareRect.minX, y: squareRect.maxY)
        let bottomRight = CGPoint(x: squareRect.maxX, y: squareRect.maxY)

        let cornerPoints = [topLeft, topRight, bottomRight, bottomLeft]

        // 3. Draw a circle at each corner
        let circleRadius: CGFloat = 8
        let circleColor = UIColor.red.cgColor

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
            circleLayer.fillColor = UIColor.clear.cgColor // Make the circle hollow
            circleLayer.strokeColor = circleColor // Add a stroke color
            circleLayer.lineWidth = 2
            view.layer.addSublayer(circleLayer)
        }
    }
}
