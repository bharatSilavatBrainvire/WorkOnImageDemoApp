//
//  FilterCVCell.swift
//  DemoImageWork
//
//  Created by Bharat Shilavat on 12/05/25.
//

import UIKit

class FilterCVCell: UICollectionViewCell {
    
    @IBOutlet weak var filterItemImageView: UIImageView!
    @IBOutlet weak var filterTypeNameLabel: UILabel!
    
    func setupFilterCellUI(with filter: ImageFilter) {
        filterTypeNameLabel.text = filter.name
        filterItemImageView.image = UIImage(systemName: filter.systemImageName)
    }
    
}
