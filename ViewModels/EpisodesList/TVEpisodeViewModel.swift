//
//  EpisodeViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation
import UIKit

// This class manages a single episode entry

class TVEpisodeViewModel: NSObject {
    
    //MARK: - Private
    private var episode: TVEpisode
    private var imageFetchingTaskId: Int?
    private let apiService: TVMazeAPIService
    
    //MARK: - Public
    
    var episodeName: String {
        return episode.name
    }
    
    var showName: String {
        return episode.show?.name ?? ""
    }
    
    var showNetwork: String {
        return episode.show?.networkName ?? ""
    }
    
    var startTime: String {

        guard let aShow = episode.show else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = aShow.timezone
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: episode.airDate)
    }
    
    init(episode: TVEpisode,
         apiService: TVMazeAPIService) {
        self.episode = episode
        self.apiService = apiService
    }
    
    /*
     Function to fetch show thumbnail.
     Uses show's original image if thumbnail is unavailable
     */
    
    func fetchShowThumbnail(completion: @escaping (UIImage?) -> Void ) {
        guard let aShow = episode.show else {
            completion(nil)
            return
        }
        
        var imageURL: URL
        var imageKey: String
        if let showThumbnailURL = aShow.thumbnailURL {
            imageURL = showThumbnailURL
            imageKey = ImageStore.thumbnailKeyFor(show: aShow)
        } else if let showImageURL = aShow.imageURL {
            imageURL = showImageURL
            imageKey = ImageStore.imageKeyFor(show: aShow)
        } else {
            print("Show does not have any images")
            completion(nil)
            return
        }
        
        if let image = ImageStore.shared.imageForKey(imageKey) {
            completion(image)
        } else {
            imageFetchingTaskId = apiService.fetchImage(atURL: imageURL) {[weak self] (imageFetchResult) in

                self?.imageFetchingTaskId = nil
                
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
    
    func cancelOngoingTasks() {
        guard let taskId = imageFetchingTaskId else {
            return
        }
        
        apiService.cancelRunningTask(withId: taskId)
        imageFetchingTaskId = nil
    }
    
    /*
     Function to return detail viewmodel for next screen.
     */
    
    func showDetailViewModel() -> TVShowDetailViewModel? {
        guard let episodeShow = episode.show else {
            print("Episode with nil show... cannot provide detail view model for now")
            return nil
        }
        
        return TVShowDetailViewModel(show: episodeShow,
                                     episode: episode,
                                     apiService: apiService)
    }
}
