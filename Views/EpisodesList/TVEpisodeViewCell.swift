//
//  TVEpisodeViewCell.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

fileprivate let defaultImage = "noImage"

class TVEpisodeViewCell: UICollectionViewCell {
    
    static let identifier = "TVEpisodeViewCell"
    
    var episodeViewModel: TVEpisodeViewModel! {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var episodeNameLabel: UILabel!
    @IBOutlet private var showNameLabel: UILabel!
    @IBOutlet private var startTimeLabel: UILabel!
    @IBOutlet private var showNetworkLabel: UILabel!
    @IBOutlet private var imageActivityIndicatorView: UIActivityIndicatorView!
    
    private var posterImage: UIImage? {
        didSet {
            if posterImage == nil {
                posterImageView.image = UIImage(named: defaultImage)
            } else {
                posterImageView.image = posterImage
            }
            imageActivityIndicatorView.stopAnimating()
        }
    }
    
    private var episodeName: String? {
        didSet {
            episodeNameLabel.text = episodeName
        }
    }
    
    private var showName: String? {
        didSet {
            showNameLabel.text = showName
        }
    }
    
    private var startTime: String? {
        didSet {
            startTimeLabel.text = startTime
        }
    }
    
    private var showNetwork: String? {
        didSet {
            showNetworkLabel.text = showNetwork
        }
    }
    
    override func prepareForReuse() {
        episodeViewModel.cancelOngoingTasks()
        
        posterImageView.image = nil
        episodeNameLabel.text = nil
        showNameLabel.text = nil
        startTimeLabel.text = nil
        showNetworkLabel.text = nil
        imageActivityIndicatorView.isHidden = false
        imageActivityIndicatorView.startAnimating()
    }
    
    func configureCell() {
        episodeName = episodeViewModel.episodeName
        showName = episodeViewModel.showName
        startTime = episodeViewModel.startTime
        showNetwork = episodeViewModel.showNetwork
        
        episodeViewModel.fetchShowThumbnail {[weak self] (image) in
            DispatchQueue.main.async {
                self?.posterImage = image
            }
        }
    }
}
