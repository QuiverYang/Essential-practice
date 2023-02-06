//
//  FeedImageCell.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/1/17.
//

import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonOnTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry:(()->Void)?
    
    @objc private func retryButtonOnTapped() {
        onRetry?()
    }
}
