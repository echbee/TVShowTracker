//
//  TVShowDetailViewModelTests.swift
//  TVShowTrackerTests
//
//  Created by Harpreet Bansal on 2018-06-15.
//  Copyright © 2018 Harpreet Bansal. All rights reserved.
//

import XCTest

@testable import TVShowTracker

class TVShowDetailViewModelTests: XCTestCase {
    
    var apiServiceMock: TVMazeAPIService!
    var mockSession: URLSessionMock!
    
    var sut: TVShowDetailViewModel!
    
    var dummyEpisode: TVEpisode {
        let dummyShow = TVShow(id: 1,
                               name: "someShow",
                               genres: ["a","b","c"],
                               networkName: "someNetwork",
                               timezone: TimeZone(identifier: "America/New_York")!,
                               thumbnailURL: URL(string: "http://someThumbnailURL")!,
                               imageURL: URL(string: "http://someImageURL")!,
                               summary: "someSummary")
        
        let dummyEpisode = TVEpisode(id: 1,
                                     name: "sampleEpisode",
                                     seasonNumber: 11,
                                     number: 2,
                                     airDate: ISO8601DateFormatter().date(from: "2018-06-25T05:30:00+00:00")!,
                                     duration: 30,
                                     showId: 26,
                                     thumbnailURL: URL(string: "http://someThumbnailURL"),
                                     imageURL: URL(string: "http://someThumbnailURL"),
                                     summary: "someSummary",
                                     show: dummyShow)
        return dummyEpisode
    }
    
    func loadDataInLocalBundle(fromPath path: String,
                               fileType:String) -> Data? {
        
        let testBundle = Bundle(for: type(of: self))
        let samplePath = testBundle.path(forResource: path, ofType: fileType)
        let data = try? Data(contentsOf: URL(fileURLWithPath: samplePath!), options: .alwaysMapped)
        
        return data
    }
    
    override func setUp() {
        mockSession = URLSessionMock()
        apiServiceMock = TVMazeAPIService(withSession: mockSession)
        
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        mockSession = nil
        apiServiceMock = nil
    }
    
    func testParametersWithValidInput() {
        
        let episode = dummyEpisode
        let show = episode.show!
        
        sut = TVShowDetailViewModel(show: show,
                                    episode: episode,
                                    apiService: apiServiceMock)
        
        XCTAssertEqual(sut.showNameString, show.name.uppercased())
        
        XCTAssertEqual(sut.showGenresString, "a | b | c ")
        XCTAssertEqual(sut.seasonNumberString, String(episode.seasonNumber))
        
        XCTAssertEqual(sut.showSummaryString.string, show.summary!)
    }
    
    func testFetchShowImageWithImageURL() {
        let episode = dummyEpisode
        let show = episode.show!
        
        sut = TVShowDetailViewModel(show: show,
                                    episode: episode,
                                    apiService: apiServiceMock)
        
        let dummyData = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        mockSession.setExpectedResponse(data: dummyData, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowImage { (fetchedImage) in
            XCTAssertNotNil(fetchedImage)
            
            XCTAssertEqual(self.mockSession.url!.absoluteString, show.imageURL?.absoluteString)
        }
    }
    
    func testFetchShowImageWithThumbnailURL() {
        let episode = dummyEpisode
        let show = TVShow(id: 1,
                          name: "someShow",
                          genres: ["a","b","c"],
                          networkName: "someNetwork",
                          timezone: TimeZone(identifier: "America/New_York")!,
                          thumbnailURL: URL(string: "http://someThumbnailURL")!,
                          imageURL: nil,
                          summary: "someSummary")
        
        episode.show = show
        
        sut = TVShowDetailViewModel(show: show,
                                    episode: episode,
                                    apiService: apiServiceMock)
        
        let dummyData = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        mockSession.setExpectedResponse(data: dummyData, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowImage { (fetchedImage) in
            XCTAssertNotNil(fetchedImage)
            
            XCTAssertEqual(self.mockSession.url!.absoluteString, show.thumbnailURL?.absoluteString)
        }
    }
    
    func testFetchShowImageWithNoURL() {
        let episode = dummyEpisode
        let show = TVShow(id: 1,
                          name: "someShow",
                          genres: ["a","b","c"],
                          networkName: "someNetwork",
                          timezone: TimeZone(identifier: "America/New_York")!,
                          thumbnailURL: nil,
                          imageURL: nil,
                          summary: "someSummary")
        
        episode.show = show
        
        sut = TVShowDetailViewModel(show: show,
                                    episode: episode,
                                    apiService: apiServiceMock)
        
        let dummyData = loadDataInLocalBundle(fromPath: "sampleImage", fileType: "jpg")
        mockSession.setExpectedResponse(data: dummyData, response: HTTPURLResponseMock(withStatusCode: 200), error: nil)
        
        sut.fetchShowImage { (fetchedImage) in
            XCTAssertNil(fetchedImage)
        }
    }
    
}
