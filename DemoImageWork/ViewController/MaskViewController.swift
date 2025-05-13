//
//  MaskViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//
import UIKit

class MaskViewController: UIViewController {
    
    var overlayView: UIView!
    var maskLayer: CAShapeLayer!
    var holeRect: CGRect!
    
    var isResizing = false
    var isCircleShape = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 1. Add content behind mask
        let label = UILabel(frame: CGRect(x: 130, y: 130, width: 150, height: 30))
        label.text = "Hello, I'm highlighted!"
        label.textColor = .black
        view.addSubview(label)
        
        // 2. Add a semi-transparent overlay
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(overlayView)
        
        // 3. Set initial hole size and position
        holeRect = CGRect(x: 100, y: 100, width: 120, height: 120)
        
        // 4. Create full rectangle path
        let fullPath = UIBezierPath(rect: overlayView.bounds)

        // 5. Create hole path (initially circle)
        let holePath = UIBezierPath(ovalIn: holeRect)

        // 6. Append hole to full path
        fullPath.append(holePath)
        fullPath.usesEvenOddFillRule = true
        
        // 7. Apply mask
        maskLayer = CAShapeLayer()
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // 8. Add pan gesture to drag the mask (hole)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        overlayView.addGestureRecognizer(panGesture)
        
        // 9. Add pinch gesture to resize the hole
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        overlayView.addGestureRecognizer(pinchGesture)
        
        // 10. Add buttons for each functionality
        setupButtons()
    }

    // MARK: - UI Setup

    func setupButtons() {
        let buttonWidth: CGFloat = 150
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 20
        let buttonYStart: CGFloat = 500
        
        // Button to Drag Mask
        let dragButton = UIButton(type: .system)
        dragButton.frame = CGRect(x: 20, y: buttonYStart, width: buttonWidth, height: buttonHeight)
        dragButton.setTitle("Drag Mask", for: .normal)
        dragButton.addTarget(self, action: #selector(dragMask), for: .touchUpInside)
        view.addSubview(dragButton)
        
        // Button to Resize Mask
        let resizeButton = UIButton(type: .system)
        resizeButton.frame = CGRect(x: 20, y: buttonYStart + buttonHeight + spacing, width: buttonWidth, height: buttonHeight)
        resizeButton.setTitle("Resize Mask", for: .normal)
        resizeButton.addTarget(self, action: #selector(resizeMask), for: .touchUpInside)
        view.addSubview(resizeButton)
        
        // Button to Toggle Shape (Circle/Square)
        let shapeButton = UIButton(type: .system)
        shapeButton.frame = CGRect(x: 20, y: buttonYStart + (buttonHeight + spacing) * 2, width: buttonWidth, height: buttonHeight)
        shapeButton.setTitle("Toggle Shape", for: .normal)
        shapeButton.addTarget(self, action: #selector(toggleMaskShape), for: .touchUpInside)
        view.addSubview(shapeButton)
        
        // Button to Reset Mask
        let resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: 20, y: buttonYStart + (buttonHeight + spacing) * 3, width: buttonWidth, height: buttonHeight)
        resetButton.setTitle("Reset Mask", for: .normal)
        resetButton.addTarget(self, action: #selector(resetMask), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // Button to Add Multiple Holes
        let holesButton = UIButton(type: .system)
        holesButton.frame = CGRect(x: 20, y: buttonYStart + (buttonHeight + spacing) * 4, width: buttonWidth, height: buttonHeight)
        holesButton.setTitle("Add Multiple Holes", for: .normal)
        holesButton.addTarget(self, action: #selector(addMultipleHoles), for: .touchUpInside)
        view.addSubview(holesButton)
    }

    // MARK: - Mask Functionalities

    @objc func dragMask() {
        print("Drag mask functionality triggered.")
        // Enable pan gesture for dragging the mask (hole)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        overlayView.addGestureRecognizer(panGesture)
    }
    
    @objc func resizeMask() {
        print("Resize mask functionality triggered.")
        // Enable pinch gesture for resizing the hole
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        overlayView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func toggleMaskShape() {
        print("Toggle mask shape functionality triggered.")
        // Toggle between circle and square
        if isCircleShape {
            holeRect = CGRect(x: 100, y: 100, width: 150, height: 150) // Square mask
        } else {
            holeRect = CGRect(x: 100, y: 100, width: 120, height: 120) // Circle mask
        }
        isCircleShape.toggle()
        updateMask()
    }
    
    @objc func resetMask() {
        print("Reset mask functionality triggered.")
        // Reset mask to default position and size
        holeRect = CGRect(x: 100, y: 100, width: 120, height: 120)
        updateMask()
    }
    
    @objc func addMultipleHoles() {
        print("Add multiple holes functionality triggered.")
        // Add multiple holes to the mask
        let fullPath = UIBezierPath(rect: overlayView.bounds)
        
        // First hole
        let firstHole = UIBezierPath(ovalIn: holeRect)
        fullPath.append(firstHole)
        
        // Second hole (different position)
        let secondHole = UIBezierPath(ovalIn: CGRect(x: 250, y: 250, width: 80, height: 80))
        fullPath.append(secondHole)
        
        // Third hole (different position)
        let thirdHole = UIBezierPath(ovalIn: CGRect(x: 400, y: 150, width: 100, height: 100))
        fullPath.append(thirdHole)
        
        fullPath.usesEvenOddFillRule = true
        maskLayer.path = fullPath.cgPath
    }

    // MARK: - Gesture Handlers
    
    // Handle pan gesture to drag the mask hole
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Update the hole's position based on gesture translation
        holeRect.origin.x += translation.x
        holeRect.origin.y += translation.y
        
        // Reset the translation after applying it
        gesture.setTranslation(.zero, in: view)
        
        // Redraw the mask with the new position of the hole
        updateMask()
    }

    // Handle pinch gesture to resize the mask hole
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        holeRect.size.width *= scale
        holeRect.size.height *= scale
        gesture.scale = 1
        
        // Redraw the mask with the new hole size
        updateMask()
    }
    
    // Update the mask with the current hole position and size
    func updateMask() {
        let fullPath = UIBezierPath(rect: overlayView.bounds)
        
        // Create hole path with updated position and size
        let holePath = UIBezierPath(ovalIn: holeRect)
        
        // Append hole to full path
        fullPath.append(holePath)
        fullPath.usesEvenOddFillRule = true
        
        // Update mask path
        maskLayer.path = fullPath.cgPath
    }
}
