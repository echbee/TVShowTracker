//
//  TVShowCastListViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-13.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

// Manages the list of TVShowCast objects for a given show id

class TVShowCastListViewModel {
    //MARK: - Private
    private let apiService: TVMazeAPIService
    
    private var showCastsViewModel: [TVShowCastViewModel]
    
    //MARK: - Public
    let showId: Int
    
    var isPopulated: Bool
    
    var count: Int {
        return showCastsViewModel.count
    }
    
    init(showId id: Int,
         apiService: TVMazeAPIService) {
        showId = id
        isPopulated = false
        self.apiService = apiService
        showCastsViewModel = [TVShowCastViewModel]()
    }
    
    /*
     Function to populate the TVShowCast objects
     */
    func populate(_ completion: @escaping () -> ()) {
        
        guard !isPopulated else {
            return
        }
        
        apiService.fetchCasts(forShow: showId) { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error getting TVShow casts - \(error.localizedDescription)")
            case .success(let showCasts):
                DispatchQueue.main.async {
                    for aShowCast in showCasts {
                        let aShowCastViewModel = TVShowCastViewModel(showCast: aShowCast,
                                                                     apiService: strongSelf.apiService)
                        strongSelf.showCastsViewModel.append(aShowCastViewModel)
                    }
                    
                    strongSelf.isPopulated = true
                    completion()
                }
            }
        }
    }
    
    subscript(index: Int) -> TVShowCastViewModel {
        get {
            return showCastsViewModel[index]
        }
    }
    
}
