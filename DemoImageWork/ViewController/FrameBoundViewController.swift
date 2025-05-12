//
//  FrameBoundViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class FrameBoundViewController: UIViewController {

    // MARK: - UI Elements
    var sampleView: UIView!
    var frameLabel: UILabel!
    var boundsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a sample view
        sampleView = UIView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        sampleView.backgroundColor = .blue
        self.view.addSubview(sampleView)
        
        // Create Labels to display frame and bounds
        frameLabel = UILabel(frame: CGRect(x: 20, y: self.view.bounds.height - 120, width: self.view.bounds.width - 40, height: 50))
        frameLabel.text = "Frame: "
        frameLabel.textColor = .black
        frameLabel.numberOfLines = 0
        self.view.addSubview(frameLabel)
        
        boundsLabel = UILabel(frame: CGRect(x: 20, y: self.view.bounds.height - 60, width: self.view.bounds.width - 40, height: 50))
        boundsLabel.text = "Bounds: "
        boundsLabel.textColor = .black
        boundsLabel.numberOfLines = 0
        self.view.addSubview(boundsLabel)
        
        // Create gesture recognizers to apply transformations
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        // Add gesture recognizers to sample view
        sampleView.addGestureRecognizer(pinchGesture)
        sampleView.addGestureRecognizer(rotationGesture)
        sampleView.addGestureRecognizer(panGesture)
        
        // Enable user interaction on the sample view
        sampleView.isUserInteractionEnabled = true
        
        // Initial update
        updateLabels()
    }
    
    // MARK: - Gesture Handlers
    
    // Handle pinch gesture (scaling)
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            sampleView.transform = sampleView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0 // Reset the scale factor
            updateLabels() // Update labels on transform
        }
    }
    
    // Handle rotation gesture
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            sampleView.transform = sampleView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0 // Reset the rotation factor
            updateLabels() // Update labels on transform
        }
    }
    
    // Handle pan gesture (translation)
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            let translation = gesture.translation(in: self.view)
            sampleView.transform = sampleView.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(.zero, in: self.view) // Reset translation
            updateLabels() // Update labels on transform
        }
    }
    
    // MARK: - Helper Method to Update Labels
    func updateLabels() {
        // Update the frame label
        let frameText = "Frame: (x: \(sampleView.frame.origin.x), y: \(sampleView.frame.origin.y), width: \(sampleView.frame.size.width), height: \(sampleView.frame.size.height))"
        frameLabel.text = frameText
        
        // Update the bounds label
        let boundsText = "Bounds: (x: \(sampleView.bounds.origin.x), y: \(sampleView.bounds.origin.y), width: \(sampleView.bounds.size.width), height: \(sampleView.bounds.size.height))"
        boundsLabel.text = boundsText
    }
}
