//
//  RestaurantItemCell+Animation.swift
//  Prototype
//
//  Created by Nazar Alwi on 02/12/21.
//

import Foundation
import UIKit

extension RestaurantItemCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        restaurantImageView.alpha = 0
        restaurantImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        restaurantImageView.alpha = 0
        restaurantImageContainer.stopShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        restaurantImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.restaurantImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.restaurantImageContainer.stopShimmering()
                }
            })
    }
}
