//
//  Gesture'sImageVC.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class GesturesImageVC: UIViewController {
    
    
    @IBOutlet weak var gestureImageView: UIImageView!
    @IBOutlet weak var gestureNameLabel: UILabel!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()

           gestureImageView.isUserInteractionEnabled = true
           addGestures()
       }

       // MARK: - Add Main ImageView Gestures
       private func addGestures() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
           gestureImageView.addGestureRecognizer(tapGesture)

           let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
           doubleTapGesture.numberOfTapsRequired = 2
           gestureImageView.addGestureRecognizer(doubleTapGesture)
           tapGesture.require(toFail: doubleTapGesture)

           let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
           gestureImageView.addGestureRecognizer(pinchGesture)

           let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
           gestureImageView.addGestureRecognizer(rotationGesture)

           let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
           gestureImageView.addGestureRecognizer(panGesture)
       }

       // MARK: - Gesture Handlers for Main Image
       @objc func handleTap(_ gesture: UITapGestureRecognizer) {
           gestureNameLabel.text = "Tap"
           print("Single tap detected")
       }

       @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
           gestureNameLabel.text = "Double Tap"
           print("Double tap detected")
           gestureImageView.transform = .identity
       }

       @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
           guard let view = gesture.view else { return }
           view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
           gesture.scale = 1
           gestureNameLabel.text = "Pinch/Scal"
       }

       @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
           guard let view = gesture.view else { return }
           view.transform = view.transform.rotated(by: gesture.rotation)
           gesture.rotation = 0
           gestureNameLabel.text = "Rotation"
       }

       @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
           let translation = gesture.translation(in: gesture.view?.superview)
           if let view = gesture.view {
               view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
           }
           gesture.setTranslation(.zero, in: gesture.view?.superview)
           gestureNameLabel.text = "Pan / Drag"
       }

       // MARK: - Add Sticker
       @IBAction func addStickerButtonTapped(_ sender: UIButton) {
           addSticker(named: "drawing-tablet")
       }

       func addSticker(named imageName: String) {
           guard let stickerImage = UIImage(named: imageName) else { return }

           let stickerImageView = UIImageView(image: stickerImage)
           stickerImageView.isUserInteractionEnabled = true
           stickerImageView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)

           let pan = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(_:)))
           let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleStickerPinch(_:)))
           let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleStickerRotate(_:)))

           stickerImageView.addGestureRecognizer(pan)
           stickerImageView.addGestureRecognizer(pinch)
           stickerImageView.addGestureRecognizer(rotate)

           self.view.addSubview(stickerImageView)
       }

       // MARK: - Sticker Gesture Handlers
       @objc func handleStickerPan(_ gesture: UIPanGestureRecognizer) {
           guard let view = gesture.view else { return }
           let translation = gesture.translation(in: self.view)
           view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
           gesture.setTranslation(.zero, in: self.view)
           gestureNameLabel.text = "Sticker Drag"
       }

       @objc func handleStickerPinch(_ gesture: UIPinchGestureRecognizer) {
           guard let view = gesture.view else { return }
           view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
           gesture.scale = 1
           gestureNameLabel.text = "Sticker Pinch"
       }

       @objc func handleStickerRotate(_ gesture: UIRotationGestureRecognizer) {
           guard let view = gesture.view else { return }
           view.transform = view.transform.rotated(by: gesture.rotation)
           gesture.rotation = 0
           gestureNameLabel.text = "Sticker Rotate"
       }
   }
