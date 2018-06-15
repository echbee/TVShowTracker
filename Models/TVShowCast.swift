//
//  TVShowCast.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-11.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation


// Represents the actual person involved with the show

class TVPerson {
    let id: Int
    let name: String
    let thumbnailURL: URL?
    let imageURL: URL?
    
    init(id personId: Int,
         name personName: String,
         thumbnailURL personThumbnailURL: URL?,
         imageURL personImageURL: URL?) {
        id = personId
        name = personName
        thumbnailURL = personThumbnailURL
        imageURL = personImageURL
    }
}

// Represents a character in any show

class TVCharacter {
    let id: Int
    let name: String
    
    init(id characterId: Int,
         name characterName: String) {
        id = characterId
        name = characterName
    }
}

// - Represents a cast of a Show

class TVShowCast {
    let person: TVPerson
    let character: TVCharacter
    let showId: Int
    
    init(showId: Int,
         person: TVPerson,
         character: TVCharacter) {
        self.showId = showId
        self.person = person
        self.character = character
    }
}

