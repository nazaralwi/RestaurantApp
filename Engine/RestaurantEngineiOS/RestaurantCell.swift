//
//  RestaurantCell.swift
//  RestaurantEngineiOS
//
//  Created by Nazar Alwi on 16/12/21.
//

import Foundation
import UIKit

public class RestaurantCell: UITableViewCell {
    public let nameLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let ratingLabel = UILabel()
    public let image = UIImageView()
    public let imageContainer = UIView()
    private(set) public lazy var imageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
