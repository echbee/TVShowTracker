//
//  TVShowDetailViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-12.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation
import UIKit

// ViewModel to manage the Show Detail View

class TVShowDetailViewModel {
    //MARK: - Private
    private let episode: TVEpisode
    private let show: TVShow
    private let apiService: TVMazeAPIService
    private var imageFetchingTaskId: Int?
    
    //MARK: - Public
    init(show: TVShow,
         episode: TVEpisode,
         apiService: TVMazeAPIService) {
        self.show = show
        self.episode = episode
        self.apiService = apiService
    }
    
    deinit {
        cancelOngoingTasks()
    }
    
    var showNameString: String {
        return show.name.uppercased()
    }
    
    var showGenresString: String {
        guard !show.genres.isEmpty else {
            return "Genre information unavailable"
        }
        
        var showGenresString = show.genres.reduce("") { (showGenres: String, aGenre) -> String in
            return showGenres.appendingFormat("%-12@ | ", aGenre)
        }
        showGenresString.removeLast()
        showGenresString.removeLast()
        
        return showGenresString
    }
    
    var seasonNumberString: String {
        return String(episode.seasonNumber)
    }
    
    var episodeNumberString: String {
        return String(episode.number)
    }
    
    var durationString: String {
        return "\(episode.duration) Minutes"
    }
    
    var showSummaryString: NSAttributedString {
        
        guard let showSummary = show.summary else {
            return NSAttributedString(string: "Show summary not available")
        }
        
        if let htmlData = showSummary.data(using: String.Encoding.unicode) {
            do {
                let attributedText = try NSAttributedString(data: htmlData,
                                                            options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil)
                
                return attributedText
            } catch let e as NSError {
                print("Couldn't translate \(showSummary): \(e.localizedDescription) ")
                return NSAttributedString(string: "")
            }
        } else {
            print("Problem parsing HTML content")
            return NSAttributedString(string: "")
        }
        
    }
    
    /*
     Function to fetch Show Image.
     Will try to fetch thumbnail if show's original image is unavailable
     */
    func fetchShowImage(_ completion: @escaping (UIImage?) -> ()) {
        
        guard show.imageURL != nil || show.thumbnailURL != nil else {
            print("No Image URL found.Cannot fetch show image.")
            completion(nil)
            return
        }
        
        var imageURL: URL
        var imageKey: String
        
        if show.imageURL != nil {
            imageURL = show.imageURL!
            imageKey = ImageStore.imageKeyFor(show: show)
        } else {
            print("Show's full res image unavailable, fetching thumbbnail...")
            imageURL = show.thumbnailURL!
            imageKey = ImageStore.thumbnailKeyFor(show: show)
        }
        
        if let image = ImageStore.shared.imageForKey(imageKey) {
            completion(image)
            return
        } else {
            imageFetchingTaskId = apiService.fetchImage(atURL: imageURL) {[weak self] (imageFetchResult) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.imageFetchingTaskId = nil
                
                switch imageFetchResult {
                case .success(let image):
                    ImageStore.shared.setImage(image, forKey: imageKey)
                    completion(image)
                case .failure(let error):
                    print("Error fetching image - \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    func getShowCastListViewModel() -> TVShowCastListViewModel {
        return TVShowCastListViewModel(showId: show.id,
                                       apiService: apiService)
    }
    
    //TODO - since EpisodeVM also does similar task, how about abstracting it in a parent class??
    func cancelOngoingTasks() {
        guard let taskId = imageFetchingTaskId else {
            return
        }
        
        apiService.cancelRunningTask(withId: taskId)
        imageFetchingTaskId = nil
    }
}
