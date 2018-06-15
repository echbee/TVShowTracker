//
//  TVShow.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

// FOR CONFORMING TO "DECODABLE"
//fileprivate struct RawTVShow: Decodable {
//
//    struct Country: Decodable {
//        let name: String
//        let code: String
//        let timezoneId: String
//    }
//
//    struct Network: Decodable {
//        let id: Int
//        let name: String
//        let country: Country
//    }
//
//    struct Image: Decodable {
//        let medium: URL?
//        let original: URL?
//    }
//
//    let id: Int
//    let name: String
//    let genres: [String]
//    let network: Network
//    let image: Image?
//    let summary: String?
//}

// Represents a TV Show

class TVShow {
    let id: Int
    let name: String
    let genres: [String]
    let networkName: String
    let timezone: TimeZone
    let thumbnailURL: URL?
    let imageURL: URL?
    let summary: String?
    
    init(id showId: Int,
         name showName: String,
         genres showGenres: [String],
         networkName showNetworkName: String,
         timezone showTimezone: TimeZone,
         thumbnailURL showThumbnailURL: URL?,
         imageURL showImageURL: URL?,
         summary showSummary: String?) {
        
        id = showId
        name = showName
        genres = showGenres
        networkName = showNetworkName
        timezone = showTimezone
        thumbnailURL = showThumbnailURL
        imageURL = showImageURL
        summary = showSummary
    }
    
//      FOR CONFORMING TO DECODABLE
//    required init(from decoder: Decoder) throws {
//        let rawResponse = try RawTVShow(from: decoder)
//
//        id = rawResponse.id
//        name = rawResponse.name
//        genres = rawResponse.genres
//        networkName = rawResponse.network.name
//        timezone = TimeZone(identifier: "America/New_York")!
//        thumbnailURL = rawResponse.image?.medium
//        imageURL = rawResponse.image?.original
//        summary = rawResponse.summary
//    }
    
}
