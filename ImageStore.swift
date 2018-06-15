//
//  ImageStore.swift
//  TVShowTracker
//
//  Created by Harpreet Bansal on 2018-06-11.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import Foundation
import UIKit

/*
 Keeps a map of (key:Image) in a local cache. Singleton
 */

class ImageStore {
    private let cache = NSCache<NSString,UIImage>()
    
    static let shared: ImageStore = {
        return ImageStore()
    }()
    
    /*
     Functions to generate keys
     */
    static func thumbnailKeyFor(show: TVShow) -> String {
        return "show-\(show.id)-thumbnail"
    }
    
    static func imageKeyFor(show: TVShow) -> String {
        return "show-\(show.id)-image"
    }
    
    static func thumbnailKeyFor(person: TVPerson) -> String {
        return "person-\(person.id)-thumbnail"
    }
    
    static func imageKeyFor(person: TVPerson) -> String {
        return "person-\(person.id)-image"
    }
    
    private init() {
        
    }
    
//        FOR SAVING IMAGES TO DISK
//    private func url(forKey key: String) ->URL {
//        let documentsDirectories =
//            FileManager.default.urls(for: .cachesDirectory,
//                                     in: .userDomainMask)
//        let documentDirectory = documentsDirectories.first!
//
//        return documentDirectory.appendingPathComponent(key)
//    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
//        FOR SAVING IMAGES TO DISK
//        let imageURL = url(forKey: key)
//
//        let imageData = UIImageJPEGRepresentation(image, 1)
//
//        do{
//            try imageData?.write(to: imageURL, options: .atomic)
//        } catch {
//            print("Problem saving the image to disk - \(error.localizedDescription)")
//        }
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        return nil
        
//        FOR SAVING IMAGES TO DISK
//        let imageURL = url(forKey: key)
//
//        if let imageFromDisk = UIImage(contentsOfFile: imageURL.path) {
//            return imageFromDisk
//        } else {
//            return nil
//        }
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)

//        FOR SAVING IMAGES TO DISK
//        let imageURL = url(forKey: key)
//        do {
//            try FileManager.default.removeItem(at: imageURL)
//        } catch {
//            print("Error removing the image from disk: \(error)")
//        }
    }
    
    
}
