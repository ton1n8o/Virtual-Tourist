//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Antonio on 1/2/18.
//  Copyright © 2018 Antônio Carlos. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    static let identifier = "PhotoViewCell"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
