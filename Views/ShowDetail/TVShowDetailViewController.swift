//
//  TVShowDetailViewController.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-12.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

fileprivate let defaultShowImage = "noImage"

class TVShowDetailViewController: UIViewController {

    @IBOutlet var showNameLabel: UILabel!
    @IBOutlet var showImageView: UIImageView!
    @IBOutlet var seasonNumberLabel: UILabel!
    @IBOutlet var episodeNumberLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var showSummaryLabel: UILabel!
    @IBOutlet var showGenresLabel: UILabel!
    @IBOutlet var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
    var showImage: UIImage? {
        didSet {
            showImageView.image = showImage ?? UIImage.init(named: defaultShowImage)
            imageLoadingActivityIndicator.stopAnimating()
        }
    }
    
    var showDetailViewModel: TVShowDetailViewModel! {
        didSet {
            fillUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fillUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showDetailViewModel.cancelOngoingTasks()
    }
    
    private func fillUI() {
        guard self.isViewLoaded && showDetailViewModel != nil else {
            return
        }
        
        showNameLabel.text = showDetailViewModel.showNameString
        seasonNumberLabel.text = showDetailViewModel.seasonNumberString
        episodeNumberLabel.text = showDetailViewModel.episodeNumberString
        durationLabel.text = showDetailViewModel.durationString
        showSummaryLabel.attributedText = showDetailViewModel.showSummaryString
        showGenresLabel.text = showDetailViewModel.showGenresString
        
        if showImage == nil {
            imageLoadingActivityIndicator.startAnimating()
            showDetailViewModel.fetchShowImage {[weak self] (image) in
                
                DispatchQueue.main.async {
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.showImage = image
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
        case "showCastListSegue":
            let castListVC = segue.destination as! TVShowCastListViewController
            castListVC.showCastListViewModel = showDetailViewModel.getShowCastListViewModel()
        default:
            print("Unidentified segue triggered")
        }
    }
}
