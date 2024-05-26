//
//  HourlyAPI.swift
//  WeatherApp
//
//  Created by Denis Raiko on 14.05.24.
//

import Foundation
import UIKit

struct HourlyWeather {
    let time: String
    let image: String
    let temp: Double
}

struct HourlyForecastResponse: Codable {
    let forecast: HourlyForecast
}

struct HourlyForecast: Codable {
    let forecastday: [HourlyForecastDay]
}

struct HourlyForecastDay: Codable {
    let hour: [Hour]
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: HourlyCondition
}

struct HourlyCondition: Codable {
    let text: String
    let icon: String
}

class HourlyAPI {
    private let apiKey = "badb39fec05f45d89bc165612241804"
    
    func sendRequest(forNumberOfDays days: Int, completion: @escaping ([HourlyWeather]) -> Void) {
        LocationManager.shared.getCurrentLocation { coordinate in
            guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(self.apiKey)&q=\(coordinate.latitude),\(coordinate.longitude)&days=\(days)&aqi=no&alerts=no") else { return }
            
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
                    let decoder = JSONDecoder()
                    let forecastData = try decoder.decode(HourlyForecastResponse.self, from: data)
                    
                    var hourlyWeather = [HourlyWeather]()
                    
                    for forecastDay in forecastData.forecast.forecastday {
                        for hour in forecastDay.hour {
                            let time = hour.time
                            let image = hour.condition.icon
                            let temp = hour.temp_c
                            
                            let hourlyWeatherItem = HourlyWeather(time: time, image: image, temp: temp)
                            hourlyWeather.append(hourlyWeatherItem)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion(hourlyWeather)
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
            session.resume()
        }
    }
}
