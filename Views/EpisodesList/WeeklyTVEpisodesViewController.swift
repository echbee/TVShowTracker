//
//  WeeklyTVEpisodesViewController.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-09.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import UIKit

class WeeklyTVEpisodesViewController: UICollectionViewController {
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    var weeklyEpisodesViewModel: WeeklyTVEpisodeListViewModel!
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows or Networks"
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = SearchableCategory.searchableCategories()
        searchController.searchBar.delegate = self
        
        //Install search controller to navigationBar
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Weekly Episodes"
        setupSearchController()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
        case "showDetailSegue":
            if let showDetailVC = segue.destination as? TVShowDetailViewController,
               let cell = sender as? TVEpisodeViewCell,
               let cellIndexPath = collectionView?.indexPath(for: cell),
               let selectedDate = weeklyEpisodesViewModel.dateFor(section: cellIndexPath.section) {
                
                showDetailVC.showDetailViewModel = weeklyEpisodesViewModel.showDetailViewModelFor(date: selectedDate,
                                                                                                  index: cellIndexPath.row)
            } else {
                print("Cannot set view model for Show Detail View Controller")
            }
            
        default:
            preconditionFailure("Unidentified segue triggered")
        }
    }
}

//MARK: - UISearchResultsUpdating
extension WeeklyTVEpisodesViewController: UISearchResultsUpdating {
    
    fileprivate func isFilteringActive() -> Bool {
        return (searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true))
    }
    
    fileprivate func activeSearchCategory() -> SearchableCategory {
        let buttonIndex = searchController.searchBar.selectedScopeButtonIndex
        
        guard let searchBarString = searchController.searchBar.scopeButtonTitles?[buttonIndex],
              let searchCategory = SearchableCategory(rawValue: searchBarString) else {
            preconditionFailure("Invalid Category found")
        }
        
        return searchCategory
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard isFilteringActive() else {
            return
        }
        
        weeklyEpisodesViewModel.filterEpisodes(withSearchText: searchController.searchBar.text!,
                      forCategory: activeSearchCategory())
        
        collectionView?.reloadData()
    }
}


//MARK: - UISearchBarDelegate
extension WeeklyTVEpisodesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            weeklyEpisodesViewModel.clearFilter()
            collectionView?.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        weeklyEpisodesViewModel.clearFilter()
        collectionView?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}


//MARK: - UICollectionViewDataSource
extension WeeklyTVEpisodesViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return weeklyEpisodesViewModel[section].count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return weeklyEpisodesViewModel.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TVEpisodeViewCell.identifier,
                                                      for: indexPath) as! TVEpisodeViewCell
        let dailyEpisodesViewModel = weeklyEpisodesViewModel[indexPath.section]
        cell.episodeViewModel = dailyEpisodesViewModel.episodeViewModel(atIndex: indexPath.row)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: TVEpisodesHeaderView.identifier,
                                                                                 for: indexPath) as! TVEpisodesHeaderView
                headerView.title = weeklyEpisodesViewModel[indexPath.section].dateString
                headerView.count = weeklyEpisodesViewModel[indexPath.section].count
                return headerView
            default:
                preconditionFailure("Cannot find the type of supplementary view")
        }
    }
}


//MARK: - UICollectionViewDelegate
extension WeeklyTVEpisodesViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplaySupplementaryView view: UICollectionReusableView,
                                 forElementKind elementKind: String,
                                 at indexPath: IndexPath) {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            weeklyEpisodesViewModel.populate(forIndex: indexPath.section) {[weak self] (didChange: Bool) -> () in
                guard didChange == true, let strongSelf = self else {
                    return
                }
                
                strongSelf.collectionView?.reloadSections(IndexSet.init(integer: indexPath.section) )
            }
        default:
            preconditionFailure("Cannot determine element kind for supplementary view")
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
extension WeeklyTVEpisodesViewController: UICollectionViewDelegateFlowLayout {
    
    private var cellApectRatio: CGFloat {
        return 0.65
    }
    
    private var itemsPerRow: CGFloat {
        if traitCollection.userInterfaceIdiom == .pad {
            return 3
        } else {
            return 1
        }
    }
    
    private var sectionInsets: UIEdgeInsets {
        if traitCollection.userInterfaceIdiom == .pad{
            return UIEdgeInsetsMake(20, 10, 20, 10) // for grid layout
        } else {
            return UIEdgeInsetsMake(10, 0, 10, 0) // for tableview style layout
        }
    }
    
    private var interItemSpacing: (horizontal: CGFloat, vertical: CGFloat) {
        if traitCollection.userInterfaceIdiom == .pad {
            return (horizontal: sectionInsets.left, vertical: sectionInsets.left)
        } else {
            return (horizontal: 0, vertical: sectionInsets.top/2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left + sectionInsets.right + interItemSpacing.horizontal * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem/cellApectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing.vertical
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing.horizontal
    }
}
