//
//  DailyTVEpisodeListViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

// Represents the categories which are searchable in a show/episode

enum SearchableCategory: String {
    case Show = "Shows"
    case Network = "Networks"
    
    static func searchableCategories() -> [String] {
        var searchableCategories = [String]()
        let dummySearchCategory = SearchableCategory.Show
        switch dummySearchCategory {
            case .Show:
                searchableCategories.append(SearchableCategory.Network.rawValue)
                fallthrough
            case .Network:
                searchableCategories.append(SearchableCategory.Show.rawValue)
            
        }
        
        return searchableCategories
    }
}

// Represents a search filter to be used for filtering episodes list

struct SearchFilter {
    var searchCategory: SearchableCategory
    var searchText: String
}

// This class manages list of episodes on a given date

class DailyTVEpisodeListViewModel: NSObject {
    
    //MARK: - Private
    private var episodesViewModel: [TVEpisodeViewModel]
    private var filteredViewModels: [TVEpisodeViewModel]
    private var searchFilter: SearchFilter? //nil if inactive
    private let apiService: TVMazeAPIService
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    //Private Functions
    private func shouldFilter(episodeViewModel: TVEpisodeViewModel) -> Bool {
        guard let activeSearchFilter = searchFilter else {
            return false
        }
        
        switch activeSearchFilter.searchCategory {
        case .Show:
            return episodeViewModel.showName.lowercased().hasPrefix(activeSearchFilter.searchText.lowercased())
        case .Network:
            return episodeViewModel.showNetwork.lowercased().hasPrefix(activeSearchFilter.searchText.lowercased())
        }
    }
    
    //MARK: - Public
    let date: Date
    var isPopulated: Bool
    
    var dateString: String {
        
        let weekdayComponent = Calendar.current.component(.weekday, from: date)
        let weekDayString = dateFormatter.weekdaySymbols[weekdayComponent - 1]
        
        let dateString = dateFormatter.string(from: date)
        
        return String(format: "%-12@ - %-12@", weekDayString, dateString)
    }
    
    var count: Int {
        if searchFilter != nil {
            return filteredViewModels.count
        } else {
            return episodesViewModel.count
        }
    }
    
    //Public Functions
    init(date: Date,
         apiService: TVMazeAPIService) {
        self.date = date
        self.apiService = apiService
        self.isPopulated = false
        episodesViewModel = [TVEpisodeViewModel]()
        filteredViewModels = [TVEpisodeViewModel]()
        
        super.init()
    }
    
    /*
     Function which populates the underlying TVEpisodeViewModel from network.
     Completion block returns a bool indicating whether data got changed
     */
    
    func populate(_ completion: @escaping (Bool) -> ()) {
        guard !isPopulated else {
            completion(false)
            return
        }
        
        apiService.fetchEpisodesForUS(on: date) { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                print("Error getting episodes - \(error.localizedDescription)")
                completion(false)
            case .success(let episodes):
                DispatchQueue.main.async {
                    for anEpisode in episodes {
                        let anEpisodeViewModel = TVEpisodeViewModel(episode: anEpisode,
                                                                    apiService: strongSelf.apiService)
                        strongSelf.episodesViewModel.append(anEpisodeViewModel)
                        
                        if strongSelf.shouldFilter(episodeViewModel: anEpisodeViewModel) {
                            strongSelf.filteredViewModels.append(anEpisodeViewModel)
                        }
                    }
                    
                    strongSelf.isPopulated = true
                    completion(true)
                }
            }
        }
    }
    
    /*
     Function to filter episodes based on text and category
     Clients must call clearFilter once filtering is complete
     */
    
    func filterEpisodes(withSearchText textToSearch: String,
                        forCategory categoryToSearch:SearchableCategory) {
        
        if searchFilter != nil {
            searchFilter!.searchCategory = categoryToSearch
            searchFilter!.searchText = textToSearch
        } else {
            searchFilter = SearchFilter(searchCategory: categoryToSearch, searchText: textToSearch)
        }
        
        filteredViewModels.removeAll()
        
        for anEpisodeViewModel in episodesViewModel {
            
            if shouldFilter(episodeViewModel: anEpisodeViewModel) {
                filteredViewModels.append(anEpisodeViewModel)
            }
        }
    }
    
    /*
     Function to clear filter applied previously
     */
    
    func clearFilter() {
        searchFilter = nil
        filteredViewModels.removeAll()
    }
    
    /*
     Function to return the underlying TVEpisodeViewModel
     */
    func episodeViewModel(atIndex index: Int) -> TVEpisodeViewModel? {
        guard index < self.count else {
            return nil
        }
        
        return ((searchFilter == nil) ? episodesViewModel[index] : filteredViewModels[index])
    }
    
    
    subscript(index: Int) -> TVEpisodeViewModel {
        get {
            return episodesViewModel[index]
        }
    }
    
}
