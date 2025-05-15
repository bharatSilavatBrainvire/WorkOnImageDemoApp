//
//  TransformViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 13/05/25.
//

import UIKit

class TransformViewController: UIViewController {
    
    let transformView = UIView()
    let resetButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTransformView()
        setupTransformButtons()
    }
    
    private func setupTransformView() {
        transformView.frame = CGRect(x: 100, y: 200, width: 150, height: 150)
        transformView.backgroundColor = .systemBlue
        view.addSubview(transformView)
    }
    
    private func setupTransformButtons() {
        let buttonTitles = ["Translate", "Rotate", "Scale", "Reset"]
        let actions: [Selector] = [
            #selector(applyTranslation),
            #selector(applyRotation),
            #selector(applyScaling),
            #selector(resetTransform)
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (title, action) in zip(buttonTitles, actions) {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .lightGray
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.topAnchor.constraint(equalTo: transformView.bottomAnchor, constant: 40),
            stackView.widthAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    // MARK: - Transform Actions

    @objc private func applyTranslation() {
        let translation = CGAffineTransform(translationX: 50, y: 50)
        transformView.transform = transformView.transform.concatenating(translation)
    }
    
    @objc private func applyRotation() {
        let rotation = CGAffineTransform(rotationAngle: .pi / 4) // 45 degrees
        transformView.transform = transformView.transform.concatenating(rotation)
    }
    
    @objc private func applyScaling() {
        let scaling = CGAffineTransform(scaleX: 1.2, y: 1.2)
        transformView.transform = transformView.transform.concatenating(scaling)
    }
    
    @objc private func resetTransform() {
        UIView.animate(withDuration: 0.3) {
            self.transformView.transform = .identity
        }
    }
}
