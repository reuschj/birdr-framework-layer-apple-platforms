import XCTest
@testable import BirdrAPIClient
@testable import BirdrModel
@testable import BirdrFoundation
@testable import BirdrAPIFoundation

private var testContext: BirdrAPIContext = .init(
    environment: .development,
    baseServiceURL: .init(all: .localhost)
)

private var imageAPI: BirdrImageAPI = .init(context: testContext)
private var spottingAPI: BirdrSpottingAPI = .init(context: testContext)

private let robinImageURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Baby_Robins_Ready_to_Feed.jpg/200px-Baby_Robins_Ready_to_Feed.jpg"


private let sampleBirdSpotting = BirdSpotting(
    title: "Look at what I found!",
    imageKeys: ["9A1FB51B-84B2-4885-8806-A7F3DD56BC18"],
    bird: .blueJay,
    location: Location(latitude: 36.375089, longitude: -94.207868),
    timestamp: 1629734637099,
    description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
)

final class BirdrAPIClientTests: XCTestCase {
    let timeout: TimeInterval = 3
    
    func testImageCreationAndRead() {
        guard let data: Data = try? .init(
            contentsOf: URL(string: robinImageURL)!
        ) else {
            XCTFail("Test image contained no data")
            return
        }
        let expectation = self.expectation(description: "Wait for response")
        let imageName = "test image"
        imageAPI.create(
            data: data,
            named: imageName
        ) { result in
            switch result {
            case .success(let imageStoreReturn):
                print(imageStoreReturn)
                XCTAssertEqual(imageStoreReturn.storedImage.type, BirdrImageAPI.SupportedImageType.jpg)
                
                // Now read...
                imageAPI.read(key: imageStoreReturn.key) { imageResult in
                    switch imageResult {
                    case .success(let imageStore):
                        print(imageStore)
                        XCTAssertEqual(imageStore.key, imageStoreReturn.key)
                        XCTAssertEqual(imageStore.type, imageStoreReturn.storedImage.type)
                        XCTAssertEqual(imageStore.name, imageName)
                        XCTAssertEqual(imageStore.data, data)
                    case .failure(let readError):
                        XCTFail(String(describing: readError))
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: timeout)
    }
    
    func testSpottingCreationAndRead() {
        let expectation = self.expectation(description: "Wait for response")
        spottingAPI.create(with: sampleBirdSpotting) { result in
            switch result {
            case .success(let birdSpottingReturn):
                // Tests
                XCTAssertEqual(birdSpottingReturn.spotting.title, sampleBirdSpotting.title)
                XCTAssertEqual(birdSpottingReturn.spotting.bird.commonName, sampleBirdSpotting.bird.commonName)
                XCTAssertEqual(birdSpottingReturn.spotting.location?.latitude, sampleBirdSpotting.location?.latitude)
                XCTAssertEqual(birdSpottingReturn.spotting.location?.longitude, sampleBirdSpotting.location?.longitude)
                XCTAssertEqual(birdSpottingReturn.spotting.description, sampleBirdSpotting.description)
                
                // Now read...
                spottingAPI.read(key: birdSpottingReturn.key) { readResult in
                    switch readResult {
                    case .success(let readSpotting):
                        // Tests
                        XCTAssertEqual(readSpotting.key, birdSpottingReturn.key)
                        XCTAssertEqual(readSpotting.title, sampleBirdSpotting.title)
                        XCTAssertEqual(readSpotting.bird.commonName, sampleBirdSpotting.bird.commonName)
                        XCTAssertEqual(readSpotting.location?.latitude, sampleBirdSpotting.location?.latitude)
                        XCTAssertEqual(readSpotting.location?.longitude, sampleBirdSpotting.location?.longitude)
                        XCTAssertEqual(readSpotting.description, sampleBirdSpotting.description)
                    case .failure(let readError):
                        XCTFail(String(describing: readError))
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail(String(describing: error))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: timeout)
    }
}
