//
//  RotationImageViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class RotationImageViewController: UIViewController {

    var imageView: UIImageView!
    var degreeTextField: UITextField!
    var rotateButton: UIButton!
    var rotateLeftButton: UIButton!
    var rotateRightButton: UIButton!
    
    private var currentRotation: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        addGestures()
    }

    func setupUI() {
        // Image View
        imageView = UIImageView(frame: CGRect(x: 60, y: 100, width: 250, height: 250))
        imageView.image = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        
        // Degree TextField
        degreeTextField = UITextField(frame: CGRect(x: 40, y: 370, width: 100, height: 40))
        degreeTextField.placeholder = "Enter °"
        degreeTextField.borderStyle = .roundedRect
        degreeTextField.keyboardType = .numberPad
        view.addSubview(degreeTextField)
        
        // Rotate Button
        rotateButton = UIButton(type: .system)
        rotateButton.frame = CGRect(x: 150, y: 370, width: 80, height: 40)
        rotateButton.setTitle("Rotate", for: .normal)
        rotateButton.addTarget(self, action: #selector(rotateFromTextField), for: .touchUpInside)
        view.addSubview(rotateButton)
        
        // Rotate Left
        rotateLeftButton = UIButton(type: .system)
        rotateLeftButton.frame = CGRect(x: 40, y: 430, width: 100, height: 40)
        rotateLeftButton.setTitle("⟲ Rotate Left", for: .normal)
        rotateLeftButton.addTarget(self, action: #selector(rotateLeft), for: .touchUpInside)
        view.addSubview(rotateLeftButton)

        // Rotate Right
        rotateRightButton = UIButton(type: .system)
        rotateRightButton.frame = CGRect(x: 160, y: 430, width: 120, height: 40)
        rotateRightButton.setTitle("Rotate Right ⟳", for: .normal)
        rotateRightButton.addTarget(self, action: #selector(rotateRight), for: .touchUpInside)
        view.addSubview(rotateRightButton)
    }
    
    func addGestures() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        imageView.addGestureRecognizer(rotationGesture)
    }

    // MARK: - Rotation Methods
    
    @objc func rotateFromTextField() {
        guard let text = degreeTextField.text, let degrees = Double(text) else { return }
        let radians = CGFloat(degrees) * CGFloat.pi / 180
        currentRotation += radians
        imageView.transform = CGAffineTransform(rotationAngle: currentRotation)
    }

    @objc func rotateLeft() {
        currentRotation -= CGFloat.pi / 2
        imageView.transform = CGAffineTransform(rotationAngle: currentRotation)
    }

    @objc func rotateRight() {
        currentRotation += CGFloat.pi / 2
        imageView.transform = CGAffineTransform(rotationAngle: currentRotation)
    }

    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            currentRotation += gesture.rotation
            imageView.transform = CGAffineTransform(rotationAngle: currentRotation)
            gesture.rotation = 0
        }
    }
}
