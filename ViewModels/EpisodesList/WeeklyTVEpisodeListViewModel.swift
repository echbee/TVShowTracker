//
//  WeeklyTVEpisodeListViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

// Class to manage DailyTVEpisodesViewModel for a given set of weekly dates

class WeeklyTVEpisodeListViewModel: NSObject {
    
    //MARK: - Private
    private var dailyEpisodesViewModel = [DailyTVEpisodeListViewModel]()
    private let apiService: TVMazeAPIService
    
    //MARK: - Public
    var count: Int {
        return dailyEpisodesViewModel.count
    }
    
    init(dates: [Date],
         apiService: TVMazeAPIService) {
        self.apiService = apiService
        for aDate in dates {
            let aDailyEpisodeVM = DailyTVEpisodeListViewModel(date:aDate,
                                                              apiService: apiService)
            dailyEpisodesViewModel.append(aDailyEpisodeVM)
        }
        super.init()
    }
    
    /*
     Function to populate the underlying viewModel for a specific date
     completion closure returns bool indicating whether data got changed
     */
    
    func populate(forIndex index:Int, completion: @escaping (Bool)->()) {
        guard !dailyEpisodesViewModel[index].isPopulated else {
            completion(false)
            return
        }
        
        dailyEpisodesViewModel[index].populate(completion)
    }
    
    //optional is kept since we do not fetch show separately right now
    func showDetailViewModelFor(date: Date,
                                index: Int) -> TVShowDetailViewModel? {
        for aViewModel in dailyEpisodesViewModel where aViewModel.date == date {
            if let anEpisodeViewModel = aViewModel.episodeViewModel(atIndex: index) {
                return anEpisodeViewModel.showDetailViewModel()
            }
        }
        
        return nil
    }
    
    func dateFor(section: Int) -> Date? {
        guard section < dailyEpisodesViewModel.count else {
            print("Cannot provide date for unknown section")
            return nil
        }
        
        return dailyEpisodesViewModel[section].date
    }
    
    /*
     Function to filter episodes.
     Calling this function entails that filtering is active.
     Clients must call clearFilter() once filtering is not required
     */
    func filterEpisodes(withSearchText searchText: String,
                        forCategory searchCategory:SearchableCategory) {
        for aDailyEpisodeViewModel in dailyEpisodesViewModel {
            aDailyEpisodeViewModel.filterEpisodes(withSearchText: searchText,
                                                  forCategory: searchCategory)
        }
    }
    
    func clearFilter() {
        for aDailyEpisodeViewModel in dailyEpisodesViewModel {
            aDailyEpisodeViewModel.clearFilter()
        }
    }
    
    subscript(index: Int) -> DailyTVEpisodeListViewModel {
        get {
            return dailyEpisodesViewModel[index]
        }
    }
    
}
