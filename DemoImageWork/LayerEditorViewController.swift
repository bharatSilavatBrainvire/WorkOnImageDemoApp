//
//  LayerEditorViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class LayerEditorViewController: UIViewController {

    // MARK: - UI Elements
    var baseImageView: UIImageView!
    var filterLayer: CALayer!
    var drawLayer: CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBaseImage()
        addButtons()
    }

    // MARK: - Setup Base Image
    private func setupBaseImage() {
        baseImageView = UIImageView(frame: CGRect(x: 20, y: 100, width: 340, height: 400))
        baseImageView.image = UIImage(named: "pexels-stephan-ernst-2151845602-31884207")
        baseImageView.contentMode = .scaleAspectFit
        baseImageView.isUserInteractionEnabled = true
        view.addSubview(baseImageView)
    }

    // MARK: - UI Buttons
    private func addButtons() {
        let stickerButton = createButton(title: "Add Sticker", action: #selector(addSticker))
        stickerButton.frame.origin.y = 520

        let filterButton = createButton(title: "Add Filter", action: #selector(addFilter))
        filterButton.frame.origin.y = 570

        let drawButton = createButton(title: "Draw Shape", action: #selector(drawOnImage))
        drawButton.frame.origin.y = 620

        view.addSubview(stickerButton)
        view.addSubview(filterButton)
        view.addSubview(drawButton)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 20, y: 0, width: 150, height: 40)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Add Sticker Layer
    @objc func addSticker() {
        guard let stickerImage = UIImage(systemName: "heart.fill") else { return }
        let stickerView = UIImageView(image: stickerImage)
        stickerView.tintColor = .red
        stickerView.frame = CGRect(x: 150, y: 150, width: 60, height: 60)
        stickerView.isUserInteractionEnabled = true
        stickerView.layer.name = "sticker"

        // Add drag gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragSticker(_:)))
        stickerView.addGestureRecognizer(pan)

        baseImageView.addSubview(stickerView)
    }

    @objc func dragSticker(_ gesture: UIPanGestureRecognizer) {
        guard let sticker = gesture.view else { return }
        let translation = gesture.translation(in: baseImageView)
        sticker.center = CGPoint(x: sticker.center.x + translation.x, y: sticker.center.y + translation.y)
        gesture.setTranslation(.zero, in: baseImageView)
    }

    // MARK: - Add Filter Layer
    @objc func addFilter() {
        // Remove existing filter if any
        filterLayer?.removeFromSuperlayer()

        filterLayer = CALayer()
        filterLayer.frame = baseImageView.bounds
        filterLayer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        filterLayer.name = "filterLayer"
        baseImageView.layer.addSublayer(filterLayer)
    }

    // MARK: - Draw Using CAShapeLayer
    @objc func drawOnImage() {
        // Remove old drawing
        drawLayer?.removeFromSuperlayer()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 20))
        path.addLine(to: CGPoint(x: 150, y: 100))
        path.addLine(to: CGPoint(x: 50, y: 200))
        path.close()

        drawLayer = CAShapeLayer()
        drawLayer.path = path.cgPath
        drawLayer.strokeColor = UIColor.blue.cgColor
        drawLayer.fillColor = UIColor.cyan.withAlphaComponent(0.3).cgColor
        drawLayer.lineWidth = 2.0

        baseImageView.layer.addSublayer(drawLayer)
    }
}
