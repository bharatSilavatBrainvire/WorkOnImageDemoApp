//
//  CoreGraphicsViewController.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit


class CoreGraphicsViewController: UIViewController {

    // MARK: - UI Elements
    var imageView: UIImageView!
    var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        setupButtons()
    }

    // MARK: - Setup Image View
    private func setupImageView() {
        imageView = UIImageView(frame: CGRect(x: 20, y: 100, width: 340, height: 300))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1
        view.addSubview(imageView)

        if let fullResImage = UIImage(named: "pexels-stephan-ernst-2151845602-31884207") {
            // Resize the image to fit the imageView's size
            let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)
            let scaledImage = renderer.image { _ in
                fullResImage.draw(in: CGRect(origin: .zero, size: imageView.frame.size))
            }

            originalImage = scaledImage
            imageView.image = scaledImage
        }
    }


    // MARK: - UI Buttons
    private func setupButtons() {
        let drawShapeButton = createButton(title: "Draw Shape", action: #selector(drawShape))
        drawShapeButton.frame.origin.y = 420

        let drawTextButton = createButton(title: "Draw Text", action: #selector(drawText))
        drawTextButton.frame.origin.y = 470

        let overlayImageButton = createButton(title: "Overlay Logo", action: #selector(drawLogo))
        overlayImageButton.frame.origin.y = 520

        view.addSubview(drawShapeButton)
        view.addSubview(drawTextButton)
        view.addSubview(overlayImageButton)
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 20, y: 0, width: 200, height: 40)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Core Graphics Actions

    // 1. Draw a Red Rectangle on the Image
    @objc func drawShape() {
        guard let baseImage = originalImage else { return }

        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let editedImage = renderer.image { context in
            baseImage.draw(at: .zero)

            let rect = CGRect(x: 50, y: 50, width: 100, height: 100)
            context.cgContext.setStrokeColor(UIColor.red.cgColor)
            context.cgContext.setLineWidth(5)
            context.cgContext.stroke(rect)
        }

        imageView.image = editedImage
    }

    // 2. Draw Text on the Image
    @objc func drawText() {
        guard let baseImage = originalImage else { return }

        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let editedImage = renderer.image { context in
            baseImage.draw(at: .zero)

            let text = "Core Graphics!"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: UIColor.green
            ]

            let textRect = CGRect(x: 20, y: 20, width: 300, height: 50)
            text.draw(in: textRect, withAttributes: attributes)
        }

        imageView.image = editedImage
    }

    // 3. Overlay Another Image (e.g., logo or icon)
    @objc func drawLogo() {
        guard let baseImage = originalImage,
              let overlay = UIImage(systemName: "star.fill") else { return }

        let renderer = UIGraphicsImageRenderer(size: baseImage.size)
        let editedImage = renderer.image { context in
            baseImage.draw(at: .zero)

            let overlaySize = CGSize(width: 60, height: 60)
            let overlayRect = CGRect(
                x: baseImage.size.width - overlaySize.width - 10,
                y: baseImage.size.height - overlaySize.height - 10,
                width: overlaySize.width,
                height: overlaySize.height
            )
            overlay.withTintColor(.yellow).draw(in: overlayRect)
        }

        imageView.image = editedImage
    }
}
