//
//  TVShowCastViewCell.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-12.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

fileprivate let defaultPersonImage = "noImage"

class TVShowCastViewCell: UICollectionViewCell {
    
    static let identifier = "TVShowCastViewCell"
    
    @IBOutlet var imageLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var personNameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var showCastViewModel: TVShowCastViewModel! {
        didSet {
            configureCell()
        }
    }
    
    private var castImage: UIImage? {
        didSet {
            if castImage == nil {
                imageView.image = UIImage(named: defaultPersonImage)
            } else {
                imageView.image = castImage
            }
            imageLoadingActivityIndicator.stopAnimating()
        }
    }
    
    override func prepareForReuse() {
        personNameLabel.text = nil
        imageView.image = nil
        
        showCastViewModel.cancelOngoingTasks()
        
        imageLoadingActivityIndicator.isHidden = false
        imageLoadingActivityIndicator.startAnimating()
    }
    
    private func configureCell() {
        personNameLabel.text = showCastViewModel.personName
        
        showCastViewModel.fetchPersonThumbnail {[weak self] (image) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.castImage = image
            }
        }
    }
}
