//
//  TVShowCastListViewController.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-12.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

class TVShowCastListViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    
    var showCastListViewModel: TVShowCastListViewModel! {
        didSet {
            populateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    private func populateUI() {
        guard isViewLoaded && showCastListViewModel != nil else {
            return
        }
        
        showCastListViewModel.populate { [weak self] in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.collectionView?.reloadData();
            }
        }
    }
}

// UICollectionViewDataSource
extension TVShowCastListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showCastListViewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TVShowCastViewCell.identifier, for: indexPath) as! TVShowCastViewCell
        
        cell.showCastViewModel = showCastListViewModel[indexPath.row]
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TVShowCastListViewController: UICollectionViewDelegateFlowLayout {
    
    private var cellApectRatio: CGFloat {
        return 0.6
    }
    
    private var sectionInsets: UIEdgeInsets {
        return UIEdgeInsetsMake(4, 10, 4, 10)
    }
    
    private var interItemSpacing: (horizontal: CGFloat, vertical: CGFloat) {
        return (horizontal: sectionInsets.left, vertical: sectionInsets.left)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.top + sectionInsets.bottom
        let heightPerItem = collectionView.frame.height - paddingSpace
        
        return CGSize(width: heightPerItem * cellApectRatio, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing.horizontal
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing.vertical
    }
}

