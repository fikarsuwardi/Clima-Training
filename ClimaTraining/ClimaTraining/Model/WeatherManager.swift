//
//  WeatherManager.swift
//  ClimaTraining
//
//  Created by Zulfikar Abdul Rahman Suwardi on 03/11/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
  func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
  func didFailWithError(error: Error)
}

struct WeatherManager {
  
  let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=ed74645a13faf424c09e393b4986712a&units=metric"
  var delegate: WeatherManagerDelegate?
  
  func fetchWeather(cityName: String) {
    let urlString = "\(weatherURL)&q=\(cityName)"
    print(urlString)
    performRequest(with: urlString)
  }
  
  func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
    performRequest(with: urlString)
  }
  
  func performRequest(with urlString: String) {
    // 1. Create a URL
    if let url = URL(string: urlString) {
      
      // 2. Create a URLSession
      let session = URLSession(configuration: .default)
      
      // 3. Give the session a task
      let task = session.dataTask(with: url) { data, response, error in
        if error != nil {
          print(error!)
          self.delegate?.didFailWithError(error: error!)
          return // mean exit out the function
        }
        // if no error then
        if let safeData = data {
          if let weather = self.parseJSON(weatherData: safeData) {
            self.delegate?.didUpdateWeather(self, weather: weather)
          }
          // gak kepake karena mau diubah ke format json
          //  let dataString = String(data: safeData, encoding: .utf8) // .utf8 is just standar
          //  print(dataString)
        }
      }
      // let task = session.dataTask(with: url, completionHandler: handle(data:response:error:)) // udah diubah ke model closure diatas
      
      // 4. Start the task
      task.resume()
    }
    
    // we dont use it cause we already sent it to closure
    //    func handle(data: Data?, response: URLResponse?, error: Error?) {
    //      if error != nil {
    //        print(error!)
    //        return // mean exit out the function
    //      }
    //      // if no error then
    //      if let safeData = data {
    //        let dataString = String(data: safeData, encoding: .utf8) // .utf8 is just standar
    //        print(dataString)
    //      }
    //    }
  }
  
  func parseJSON(weatherData: Data) -> WeatherModel? {
    let decoder = JSONDecoder()
    do {
      let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
      //      print(decodeData.name)
      //      print(decodeData.main.temp) // will be error cause u have to defined it in Weather Data
      //      print(decodeData.weather[0].description)
      //      print(decodeData.coord.lon, decodeData.coord.lat)
      //      print(decodeData.base)
      //      print(decodeData.main.feels_like)
      
      let id = decodeData.weather[0].id
      let temp = decodeData.main.temp
      let name = decodeData.name
      
      let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
      print(weather.conditionName)
      print(decodeData.main.temp)
      print(weather.temperatureString)
      
      return weather
    } catch {
      print(error)
      delegate?.didFailWithError(error: error)
      return nil
    }
  }
  
}
