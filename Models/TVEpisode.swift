//
//  Episode.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

// Represents a TV Episode

class TVEpisode {
    let id: Int
    let name: String
    let seasonNumber: Int
    let number: Int
    let airDate: Date
    let duration: Int
    let showId: Int
    let thumbnailURL: URL?
    let imageURL: URL?
    let summary: String?
    var show: TVShow?
    
    init(id episodeId: Int,
         name episodeName: String,
         seasonNumber episodeSeasonNumber: Int,
         number episodeNumber: Int,
         airDate episodeAirDate: Date,
         duration episodeDuration: Int,
         showId episodeShowId: Int,
         thumbnailURL episodeThumbnailURL: URL?,
         imageURL episodeImageURL: URL?,
         summary episodeSummary: String?,
         show episodeShow: TVShow?) {
        
        id = episodeId
        name = episodeName
        seasonNumber = episodeSeasonNumber
        number = episodeNumber
        airDate = episodeAirDate
        duration = episodeDuration
        showId = episodeShowId
        thumbnailURL = episodeThumbnailURL
        imageURL = episodeImageURL
        summary = episodeSummary
        show = episodeShow
        
    }
}
