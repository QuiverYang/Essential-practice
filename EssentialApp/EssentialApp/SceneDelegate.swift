//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Menglin Yang on 2023/4/27.
//

import UIKit
import Essentail_practice
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }
    func configureWindow() {
        
//        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        let httpClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        
        let store = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

        let remoteImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageDataLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(rootViewController:  FeedUIComposer.feedComposeWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageDataLoader, cache: localImageDataLoader),
                fallback: localImageDataLoader)))
    }
    
    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

}
