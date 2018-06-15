//
//  TVMazeAPI.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-10.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation

/*
 TVMazeAPI handles the following responsibility:
 1. Provide URL for endpoints
 2. Parsing logic
 */

struct TVMazeAPI {
    
    /*
     Required Enums for different endpoints
     */
    
    enum CountryCode: String {
        case US
    }
    
    enum Endpoints {
        case schedule
        case showCast(showId: Int)
    }
    
    private static let baseURLString = "http://api.tvmaze.com"
    
    /*
     Returns the URL for a specific endpoint
     */
    private static func URLForEndpoint(_ endpoint: Endpoints) -> URL {
        var url = URL(string: baseURLString)!
        
        switch endpoint {
            case .schedule:
                url.appendPathComponent("schedule")
            case .showCast(let showId):
                url.appendPathComponent("shows/\(showId)/cast")
        }
        
        return url
    }
    
    /*
     Functions to parse image components.
     
     Data must come in following format
     -----------
     {
        "image": {
            "medium": "http://static.tvmaze.com/uploads/images/medium_portrait/95/239275.jpg",
            "original": "http://static.tvmaze.com/uploads/images/original_untouched/95/239275.jpg"
        }
     }
     -----------
     
     */
    
    private static func parseImageComponent(fromJSON jsonData: Any) -> (lowResURL: URL?, fullResURL: URL?) {
        
        guard let jsonDict = jsonData as? [String:Any],
              let imagesDict = jsonDict["image"] as? [String:String] else {
            return (lowResURL: nil, fullResURL: nil)
        }
        
        var lowResURL: URL?
        var fullResURL: URL?
        
        if let lowResURLString = imagesDict["medium"] {
            lowResURL = URL(string: lowResURLString)
        }
    
        if let fullResURLString = imagesDict["original"] {
            fullResURL = URL(string: fullResURLString)
        }

        return (lowResURL: lowResURL, fullResURL: fullResURL)
        
    }
    
    private static func parseTVPerson(fromJSON jsonData: Any) -> TVPerson? {
        guard let jsonDict = jsonData as? [String:Any],
              let personDict = jsonDict["person"] as? [String:Any],
              let personId = personDict["id"] as? Int,
              let personName = personDict["name"] as? String else {
                print("Problem parsing TV Person")
                return nil
        }
        
        let imageData = parseImageComponent(fromJSON: personDict)
        
        let aPerson = TVPerson(id: personId,
                               name: personName,
                               thumbnailURL: imageData.lowResURL,
                               imageURL: imageData.fullResURL)
        
        return aPerson
    }
    
    private static func parseTVCharacter(fromJSON jsonData: Any) -> TVCharacter? {
        guard let jsonDict = jsonData as? [String:Any],
              let characterDict = jsonDict["character"] as? [String:Any],
              let characterId = characterDict["id"] as? Int,
              let characterName = characterDict["name"] as? String else {
                print("Problem parsing TV Character")
                return nil
        }
        
        let aTVCharacter = TVCharacter(id: characterId,
                                       name: characterName)
        
        return aTVCharacter
    }
    
    private static func parseTVShowCast(forShowId showId: Int,
                                        fromJSON jsonData: Any) -> TVShowCast? {
        guard let castDict = jsonData as? [String:Any],
              let person = parseTVPerson(fromJSON: castDict),
              let character = parseTVCharacter(fromJSON: castDict) else {
                print("Problem parsing TVShow Cast")
                return nil
        }
        
        let aCast = TVShowCast(showId: showId,
                               person: person,
                               character: character)
        
        return aCast
    }
    
    private static func parseTVShow(fromJSON jsonObject: Any) -> TVShow? {
        guard let jsonDictionary = jsonObject as? [String:Any],
              let showId = jsonDictionary["id"] as? Int,
              let showName = jsonDictionary["name"] as? String,
              let showGenres = jsonDictionary["genres"] as? [String],
              let networkDict = jsonDictionary["network"] as? [String:Any],
              let showNetwork = networkDict["name"] as? String,
              let networkCountryDict = networkDict["country"] as? [String:String],
              let showTimezoneId = networkCountryDict["timezone"],
              let showTimezone = TimeZone(identifier: showTimezoneId) else {
                print("Show Parsing Error: Required values not found..")
                return nil
        }
        
        var summary: String?
        
        let imagesData = parseImageComponent(fromJSON: jsonDictionary)
        
        if let showSummary = jsonDictionary["summary"] as? String {
            summary = showSummary
        }
        
        let show = TVShow(id: showId,
                          name: showName,
                          genres: showGenres,
                          networkName: showNetwork,
                          timezone: showTimezone,
                          thumbnailURL: imagesData.lowResURL,
                          imageURL: imagesData.fullResURL,
                          summary: summary)
        
        return show
    }
    
    /*
     Function to parse an episode which must have "show" data in it.
     Suitable when getting list of episodes for a single date
     */
    
    private static func parseEpisodeWithShow(forShowId showId: Int?,
                                     fromJSON jsonObject: Any) -> TVEpisode? {
        do {
            guard let jsonDictionary = jsonObject as? [String:Any] else {
                print("Episode data not in correct format")
                return nil
            }
            
            var summary: String?
            var show: TVShow?
            var idOfShow: Int
            
            if let showDictionary = jsonDictionary["show"] as? [String:Any] {
                show = parseTVShow(fromJSON: showDictionary)
            }
            
            if show == nil && showId == nil {
                print("Cannot create episode without show information")
                return nil
            } else {
                idOfShow = show?.id ?? showId!
            }
            
            guard let episodeId = jsonDictionary["id"] as? Int,
                  let episodeName = jsonDictionary["name"] as? String,
                  let episodeAirstamp = jsonDictionary["airstamp"] as? String,
                  let episodeAirDate = Utilities.ISO8601Date(from: episodeAirstamp),
                  let seasonNumber = jsonDictionary["season"] as? Int,
                  let episodeNumber = jsonDictionary["number"] as? Int,
                  let duration = jsonDictionary["runtime"] as? Int else {
                    print("Episode Parsing Error: Could not find all required values.")
                    return nil
            }
            
            let imagesData = parseImageComponent(fromJSON: jsonDictionary)
            
            if let episodeSummary = jsonDictionary["summary"] as? String {
                summary = episodeSummary
            }
            
            let episode = TVEpisode(id: episodeId,
                                    name: episodeName,
                                    seasonNumber: seasonNumber,
                                    number: episodeNumber,
                                    airDate: episodeAirDate,
                                    duration: duration,
                                    showId: idOfShow,
                                    thumbnailURL: imagesData.lowResURL,
                                    imageURL: imagesData.fullResURL,
                                    summary: summary,
                                    show: show)
            
            return episode
            
        }
    }
    
    /*
     Generic function to parse any Type given in a List format in JSON.
     ExampleData:
     [
     
        { //Type Object 1
            ---DATA---
        },
        { //Type Object 2
            ---DATA---
        }
     ]
     */
    
    private static func parseListData<Type>(from data:Data,
                                            parser: (Any) -> Type? ) -> [Type]? {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let typeListData = jsonData as? [Any] else {
                return nil
            }
            
            var typeObjectList = [Type]()
            
            for typeData in typeListData {
                if let typeObject = parser(typeData) {
                    typeObjectList.append(typeObject)
                }
            }
            
            if typeObjectList.isEmpty {
                print("No parsable Objects found")
                return nil
            }
            
            return typeObjectList
        } catch {
            print("Error occured:\(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - URL generating functions
    
    /*
     Returns episodes schedule URL for specific date and country code
     */
    
    static func episodeScheduleURL(for countryCode: CountryCode,
                                   date: Date) -> URL? {
        let formattedDate = ISO8601DateFormatter.string(from: date, timeZone: TimeZone.current, formatOptions: [.withYear,.withMonth,.withDay,.withDashSeparatorInDate] )
        
        var components = URLComponents(url:  URLForEndpoint(.schedule), resolvingAgainstBaseURL: false)
        let countryCodeQueryItem = URLQueryItem(name: "country", value: countryCode.rawValue)
        let dateQueryItem = URLQueryItem(name: "date", value: formattedDate)
        components?.queryItems = [countryCodeQueryItem,dateQueryItem]
        
        return components?.url
    }
    
    static func showCastURL(forShowId id: Int) -> URL? {
        let components = URLComponents(url: URLForEndpoint(Endpoints.showCast(showId: id)), resolvingAgainstBaseURL: false)
        return components?.url
    }
    
    //MARK: - Public Parsing functions
    
    static func parseEpisodesWithShow(from data:Data) -> [TVEpisode]? {
        let episodeParser = { (jsonData:Any) -> TVEpisode? in
            return parseEpisodeWithShow(forShowId: nil, fromJSON: jsonData)
        }
        
        return parseListData(from: data, parser: episodeParser)
    }
    
    static func parseShowCast(from data: Data,
                              forShowId showId: Int) -> [TVShowCast]? {
        let showCastParser = { (jsonData:Any) -> TVShowCast? in
            return parseTVShowCast(forShowId: showId, fromJSON: jsonData)
        }
        
        return parseListData(from: data, parser: showCastParser)
        
    }
    
    
}
