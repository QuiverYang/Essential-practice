//
//  FeedSnapshotTests.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/5/15.
//

import XCTest
import EssentialPracticeiOS


final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let controller = UIStoryboard(name: "Feed", bundle: bundle).instantiateInitialViewController() as! FeedViewController
        controller.loadView()
        return controller
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = snapshot.pngData()
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            
            try FileManager.default.createDirectory(
                at:snapshotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
    }
    
    private func emptyFeed() -> [FeedImageCellController]{
        return []
    }

}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
