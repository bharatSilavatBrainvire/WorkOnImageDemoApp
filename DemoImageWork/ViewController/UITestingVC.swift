//
//  UITestingVC.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//

import UIKit

class UITestingVC: UIViewController {
    
    // MARK: - UI Elements
    var redView: UIView!
    var maskLayer: CAShapeLayer!
    var shapeSlider: UISlider!
    var showMaskButton: UIButton!
    
    var frameLabel: UILabel!
    var boundsLabel: UILabel!
    var positionLabel: UILabel!
    var maskLabel: UILabel!
    var clipsToBoundsLabel: UILabel!
    var transformLabel: UILabel!
    var alphaLabel: UILabel!
    var backgroundColorLabel: UILabel!
    var featureNameLabel: UILabel!
    
    var maskEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Create the red view
        redView = UIView()
        redView.frame = CGRect(x: 100, y: 150, width: 200, height: 200)
        redView.backgroundColor = .red
        redView.isUserInteractionEnabled = true
        view.addSubview(redView)
        
        // Setup UI
        createLabels()
        setupGestures()
        
        // Create initial mask
        maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(ovalIn: redView.bounds).cgPath
        redView.layer.mask = maskLayer
        
        // Add slider to change mask shape
        shapeSlider = UISlider(frame: CGRect(x: 50, y: 700, width: 300, height: 30))
        shapeSlider.minimumValue = 0
        shapeSlider.maximumValue = 1
        shapeSlider.value = 0
        shapeSlider.addTarget(self, action: #selector(maskShapeChanged), for: .valueChanged)
        view.addSubview(shapeSlider)
        
        // Add button to toggle mask
        showMaskButton = UIButton(type: .system)
        showMaskButton.frame = CGRect(x: 100, y: 750, width: 200, height: 40)
        showMaskButton.setTitle("Toggle Mask Visibility", for: .normal)
        showMaskButton.addTarget(self, action: #selector(toggleMaskVisibility), for: .touchUpInside)
        view.addSubview(showMaskButton)
        
        // Update labels
        updateLabels()
    }
    
    // MARK: - Label Setup
    func createLabels() {
        frameLabel = createLabel(at: CGPoint(x: 20, y: 90), text: "Frame:")
        boundsLabel = createLabel(at: CGPoint(x: 20, y: 120), text: "Bounds:")
        positionLabel = createLabel(at: CGPoint(x: 20, y: 150), text: "Position:")
        maskLabel = createLabel(at: CGPoint(x: 20, y: 180), text: "Mask:")
        clipsToBoundsLabel = createLabel(at: CGPoint(x: 20, y: 210), text: "ClipsToBounds:")
        transformLabel = createLabel(at: CGPoint(x: 20, y: 240), text: "Transform:")
        alphaLabel = createLabel(at: CGPoint(x: 20, y: 270), text: "Alpha:")
        backgroundColorLabel = createLabel(at: CGPoint(x: 20, y: 300), text: "Background Color:")
        featureNameLabel = createLabel(at: CGPoint(x: 20, y: 330), text: "Gesture:")
        
        [frameLabel, boundsLabel, positionLabel, maskLabel,
         clipsToBoundsLabel, transformLabel, alphaLabel,
         backgroundColorLabel, featureNameLabel].forEach(view.addSubview)
    }
    
    func createLabel(at point: CGPoint, text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: point.x, y: point.y, width: 350, height: 40))
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .black
        label.text = text
        return label
    }
    
    // MARK: - Update Labels
    func updateLabels() {
        frameLabel.text = "Frame: \(redView.frame)"
        boundsLabel.text = "Bounds: \(redView.bounds)"
        positionLabel.text = "Position: \(redView.center)"
        maskLabel.text = redView.layer.mask != nil ? "Mask: Active" : "Mask: None"
        clipsToBoundsLabel.text = "ClipsToBounds: \(redView.clipsToBounds)"
        transformLabel.text = "Transform: \(redView.transform)"
        alphaLabel.text = "Alpha: \(redView.alpha)"
        backgroundColorLabel.text = "Background Color: \(redView.backgroundColor?.description ?? "nil")"
    }
    
    // MARK: - Gestures
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        redView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        redView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        redView.addGestureRecognizer(rotationGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        redView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        redView.addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            gesture.setTranslation(.zero, in: self.view)
            featureNameLabel.text = "Gesture: Pan"
            updateLabels()
        }
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
            featureNameLabel.text = "Gesture: Pinch"
            updateLabels()
        }
    }
    
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
            featureNameLabel.text = "Gesture: Rotation"
            updateLabels()
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        featureNameLabel.text = "Gesture: Tap"
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        redView.transform = .identity
        featureNameLabel.text = "Gesture: Double Tap (Reset)"
        updateLabels()
    }
    
    // MARK: - Mask Logic
    @objc func maskShapeChanged() {
        let value = shapeSlider.value
        if value < 0.5 {
            maskLayer.path = UIBezierPath(ovalIn: redView.bounds).cgPath
        } else {
            maskLayer.path = UIBezierPath(rect: redView.bounds).cgPath
        }
        updateLabels()
    }
    
    @objc func toggleMaskVisibility() {
        if maskEnabled {
            redView.layer.mask = nil
            showMaskButton.setTitle("Show Mask", for: .normal)
        } else {
            redView.layer.mask = maskLayer
            showMaskButton.setTitle("Hide Mask", for: .normal)
        }
        maskEnabled.toggle()
        updateLabels()
    }
}
