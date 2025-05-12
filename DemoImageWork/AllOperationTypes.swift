//
//  AllOperationTypes.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

enum ImageOperationType: String, CaseIterable {
    case workspace = "Workspace"
    case stickers = "Stickers"
    case pinchGestures = "Pinch Gestures"
    case taps = "Taps"
    case doubleTap = "Double Tap"
    case rotation = "Rotation"
    case scale = "Scale"
    case layer = "Layer"
    case crop = "Crop"
    case edges = "Edges"
    case filters = "Filters"
    case bound = "Bound"
    case frame = "Frame"
    case srt = "S, R, T"
    case coordinates = "Coordinates"
    case coreImage = "Core Image"
    case imageSave = "Image Save Code"
    case cgContext = "CG Context"
    case coreGraphics = "Core Graphics"
}

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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOperation = ImageOperationType.allCases[indexPath.row]
        
        var vc: UIViewController?

        switch selectedOperation {
        case .doubleTap, .pinchGestures,.stickers:
            vc = storyboard?.instantiateViewController(withIdentifier: "GesturesImageVC")
            
        case .crop:
            vc = storyboard?.instantiateViewController(withIdentifier: "CropViewController")
            
        case .filters:
            vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController")
                 
        case .imageSave:
            vc = storyboard?.instantiateViewController(withIdentifier: "SaveImageViewController")

        case .layer:
            vc = storyboard?.instantiateViewController(withIdentifier: "LayerEditorViewController")
        // Add other cases as you create their VCs...
        case .coreGraphics:
            vc = self.storyboard?.instantiateViewController(withIdentifier: "CoreGraphicsViewController")
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
