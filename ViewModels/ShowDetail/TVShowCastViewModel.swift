//
//  TVShowCastViewModel.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-12.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation
import UIKit

// ViewModel to manage a single TVShowCast

class TVShowCastViewModel {
    //MARK: - Private
    private var cast: TVShowCast
    
    //TODO - think about generalizing it across ViewModels
    private var imageFetchingTaskId: Int?
    
    private let apiService: TVMazeAPIService
    
    //MARK: - Public
    
    init(showCast: TVShowCast,
         apiService: TVMazeAPIService) {
        cast = showCast
        self.apiService = apiService
    }
    
    var personName: String {
        return cast.person.name
    }
    
    /*
     Function to fetch a person's thumbnail.
     Will fetch original image if thumbnail is unavailable
     */
    
    func fetchPersonThumbnail(_ completion: @escaping (UIImage?) -> Void) {
        guard cast.person.thumbnailURL != nil || cast.person.imageURL != nil else {
            print("Cannot find a person's image to fetch")
            completion(nil)
            return
        }
        
        var imageURL: URL
        var imageKey: String
        if let personThumbnailURL = cast.person.thumbnailURL {
            imageURL = personThumbnailURL
            imageKey = ImageStore.thumbnailKeyFor(person: cast.person)
        } else {
            imageURL = cast.person.imageURL!
            imageKey = ImageStore.imageKeyFor(person: cast.person)
        }
        
        if let image = ImageStore.shared.imageForKey(imageKey) {
            completion(image)
            return
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
    
    /*
     Function to cancel any outgoing network tasks
     */
    
    func cancelOngoingTasks() {
        guard let taskId = imageFetchingTaskId else {
            return
        }
        
        apiService.cancelRunningTask(withId: taskId)
        imageFetchingTaskId = nil
    }
}
