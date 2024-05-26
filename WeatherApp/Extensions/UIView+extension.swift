//
//  UIView+extension.swift
//  WeatherApp
//
//  Created by Denis Raiko on 8.05.24.
//

import Foundation
import UIKit

extension UIView {
    func addGradient(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

