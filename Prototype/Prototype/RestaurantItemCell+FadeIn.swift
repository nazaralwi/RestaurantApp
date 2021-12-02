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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        restaurantImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        restaurantImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: []) {
                self.restaurantImageView.alpha = 1
            }
    }
}
