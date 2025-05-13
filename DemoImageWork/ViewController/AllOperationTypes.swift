//
//  AllOperationTypes.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class AllOperationTypes: UIViewController {
    
    var tableView: UITableView!

    
    @IBOutlet weak var operationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        operationTableView.delegate = self
        operationTableView.dataSource = self
    }
}

extension AllOperationTypes: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageOperationType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let operation = ImageOperationType.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath)
        cell.textLabel?.text = operation.rawValue
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOperation = ImageOperationType.allCases[indexPath.row]
        
        var vc: UIViewController?

        switch selectedOperation {
        case .doubleTap, .pinchGestures,.stickers, .taps:
            vc = storyboard?.instantiateViewController(withIdentifier: "GesturesImageVC")
                 
        case .layer:
            vc = storyboard?.instantiateViewController(withIdentifier: "LayerEditorViewController")
        // Add other cases as you create their VCs...
        case .coreGraphics:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "CoreGraphicsViewController")
            
        case .cgContext:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "CGContextDrawingViewController")
        case .coreImage,.imageSave:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "CoreImageViewController")
        case .compositing, .coordinates:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageEditorViewController")
        case .frame, .bound:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "FrameBoundVC")
        case .edges:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "EdgeDetectionViewController")
        case .rotation:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "RotationImageViewController")
        case .allInOne:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "AllInOneViewController")
        case .uiTesting:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "UITestingVC")
        case .mask:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "MaskViewController")
        default:
            print("No VC assigned for \(selectedOperation.rawValue)")
        }

        if let destinationVC = vc {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        } else {
            print("ViewController not found for selected operation.")
        }
    }
}
