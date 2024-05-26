//
//  Strings+extension.swift
//  WeatherApp
//
//  Created by Denis Raiko on 21.05.24.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
