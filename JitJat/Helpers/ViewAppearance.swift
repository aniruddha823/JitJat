//
//  ViewAppearance.swift
//  JitJat
//
//  Created by Aniruddha Prabhu on 2/26/19.
//  Copyright © 2019 Aniruddha Prabhu. All rights reserved.
//

import Foundation
import UIKit

class ViewAppearance {
    
    class func setupViewContainer(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 1
        view.layer.shadowColor = #colorLiteral(red: 0.8450792293, green: 0.8425879095, blue: 0.8439994079, alpha: 1)
    }
    
    class func setupCircularImageView(view: UIImageView) {
        view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = view.bounds.height / 2
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
    }
}
