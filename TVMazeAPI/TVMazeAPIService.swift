//
//  TVMazeAPIService.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation
import UIKit

//MAKE EVERYTHING STATIC - remove shared

class TVMazeAPIService {
    
    // MARK: Enums
    enum HTTPStatusCode: Int {
        case success = 200
    }

    enum TVMazeAPIError: Error, LocalizedError {
        case invalidHTTPResponseCode(code: Int)
        case invalidDataReturned
        
        var errorDescription: String {
            switch self {
            case .invalidHTTPResponseCode(code: let statusCode):
                return "Invalid HTTP status code - \(statusCode)"
            case .invalidDataReturned:
                return "Invalid data in HTTP response"
            }
        }
    }
    
    enum TVMazeAPIFetchResult<Type> {
        case success(Type)
        case failure(Error)
    }
    
    typealias EpisodesFetchResult = TVMazeAPIFetchResult<[TVEpisode]>
    typealias ImageFetchResult = TVMazeAPIFetchResult<UIImage>
    typealias ShowCastsFetchResult = TVMazeAPIFetchResult<[TVShowCast]>
    
    /*
     Generic Function to fetch from a URL and check for errors and parse content
     */
    
    @discardableResult private func fetchFromTVMazeAPI<Type>(url: URL,
                                                              expectedHTTPCode: Int,
                                                              parser: @escaping (Data) -> (Type?),
                                                              _ completion: @escaping (TVMazeAPIFetchResult<Type>) -> Void) -> Int {
        let fetchTask = urlSession.dataTask(with: url) { (data, response, error) in
            //check error and http status codes
            if let someError = error {
                print("Error while fetching episodes")
                completion(.failure(someError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode != expectedHTTPCode {
                print("Wrong HTTP status code received:\(httpResponse.statusCode)")
                completion(.failure(TVMazeAPIError.invalidHTTPResponseCode(code: httpResponse.statusCode)))
                return
            }
            
            // parse data
            if let fetchedData = data, let typeObject = parser(fetchedData) {
                completion(.success(typeObject))
            } else {
                completion(.failure(TVMazeAPIError.invalidDataReturned))
            }
            
        }
        
        fetchTask.resume()
        return fetchTask.taskIdentifier
    }
    
    // URLSession to use for network requests
    private let urlSession: URLSession
    
    //MARK: - Public
    
    init(withSession session: URLSession) {
        urlSession = session
    }
    
    /*
     Function to fetch episodes list for US and return results.
     Returns the task ID if task is started
     */
    @discardableResult func fetchEpisodesForUS(on date: Date, _ completion: @escaping (EpisodesFetchResult) -> Void) -> Int? {
        guard let url = TVMazeAPI.episodeScheduleURL(for: .US, date: date) else {
            return nil
        }
        
        return fetchFromTVMazeAPI(url: url,
                                  expectedHTTPCode: HTTPStatusCode.success.rawValue,
                                  parser: TVMazeAPI.parseEpisodesWithShow,
                                  completion)
        
    }
    
    @discardableResult func fetchCasts(forShow showId: Int, _ completion: @escaping (ShowCastsFetchResult) -> ()) -> Int? {
        guard let url = TVMazeAPI.showCastURL(forShowId: showId) else {
            return nil
        }
        
        let showCastsParser = { (data: Data) -> [TVShowCast]? in
            return TVMazeAPI.parseShowCast(from: data,
                                           forShowId: showId)
        }
        
        return fetchFromTVMazeAPI(url: url,
                                  expectedHTTPCode: HTTPStatusCode.success.rawValue,
                                  parser: showCastsParser,
                                  completion)
        
    }
    
    /*
     Function to fetch image from a URL.
     Returns the task ID if task is started
     */
    
    @discardableResult func fetchImage(atURL url: URL, _ completion: @escaping (ImageFetchResult) -> () ) -> Int? {
        
        return fetchFromTVMazeAPI(url: url,
                                  expectedHTTPCode: HTTPStatusCode.success.rawValue,
                                  parser: UIImage.init(data:),
                                  completion)
    }
    
    /*
     Function to cancel any running tasks
     */
    
    func cancelRunningTask(withId taskId: Int) {
        urlSession.getTasksWithCompletionHandler{ (dataTasksList, _, _) in
            for dataTask in dataTasksList where dataTask.taskIdentifier == taskId {
                dataTask.cancel()
            }
        }
    }
}
