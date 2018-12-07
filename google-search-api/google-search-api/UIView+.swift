//
//  UIView+.swift
//  google-search-api
//
//  Created by Kubitski Vlad on 07.12.2018.
//  Copyright © 2018 Kubitski Vlad. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    static func loadFromXib<T: UIView>() -> T {
        let string = NSStringFromClass(object_getClass(self)!).split(separator: ".").last!
        let array = Bundle.main.loadNibNamed(String(string), owner: self, options: nil)
        let item = array?.last as? T
        return item!
    }
}
