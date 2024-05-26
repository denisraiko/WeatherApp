//
//  DailyAPI.swift
//  WeatherApp
//
//  Created by Denis Raiko on 11.05.24.
//

import Foundation
import UIKit

struct DailyWeather {
    let date: String
    let image: String
    let minTemp: Double
    let maxTemp: Double
}

struct ForecastResponse: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
}


class DailyAPI {
    private let apiKey = "badb39fec05f45d89bc165612241804"
    
    func sendRequest(forNumberOfDays days: Int, completion: @escaping ([DailyWeather]) -> Void) {
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
                    let forecastData = try decoder.decode(ForecastResponse.self, from: data)
                    
                    var dailyWeather = [DailyWeather]()
                    
                    for forecastDay in forecastData.forecast.forecastday {
                        let date = forecastDay.date
                        let day = forecastDay.day
                        let maxTemperature = day.maxtemp_c
                        let minTemperature = day.mintemp_c
                        let condition = day.condition
                        let icon = condition.icon
                        
                        let dailyWeatherItem = DailyWeather(date: date, image: icon, minTemp: minTemperature, maxTemp: maxTemperature)
                        dailyWeather.append(dailyWeatherItem)
                    }
                    
                    DispatchQueue.main.async {
                        completion(dailyWeather)
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
            
            session.resume()
        }
    }
}






