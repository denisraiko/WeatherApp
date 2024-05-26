//
//  CurrentAPI.swift
//  WeatherApp
//
//  Created by Denis Raiko on 11.05.24.
//

import Foundation
import UIKit

class CurrentAPI {
    private let apiKey = "badb39fec05f45d89bc165612241804"
    
    func sendRequest(locationLabel: UILabel, tempLabel: UILabel, conditionLabel: UILabel, icon: UIImageView, titleUpdater: @escaping (String) -> Void) {
        LocationManager.shared.getCurrentLocation { coordinate in
            
            guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(self.apiKey)&q=\(coordinate.latitude),\(coordinate.longitude)&days=1&aqi=no&alerts=no") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Request error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let location = json["location"] as? [String: Any],
                           let name = location["name"] as? String,
                           let region = location["region"] as? String,
                           let country = location["country"] as? String,
                           let fullName = "\(name), \(country)" as? String,
                           let current = json["current"] as? [String: Any],
                           let temp = current["temp_c"] as? Double,
                           let condition = current["condition"] as? [String: Any],
                           let text = condition["text"] as? String,
                           let image = condition["icon"] as? String
                        {
                            DispatchQueue.main.async {
                                locationLabel.text = name
                                tempLabel.text = "\(Int(temp))°C"
                                conditionLabel.text = text
                                
                                // Загрузка изображения по URL
                                if let imageURL = URL(string: "https:\(image)") {
                                    self.loadImage(from: imageURL) { downloadedImage in
                                        icon.image = downloadedImage
                                    }
                                }
                                
                                titleUpdater(fullName)
                            }
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
            session.resume()
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}


