//
//  CentralComponents.swift
//  WeatherApp
//
//  Created by Vadim Popov on 22.03.2024.
//

import UIKit
import Combine


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}


class CentralImageComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UIImageView
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let image = UIImage(named: "cloud.sun")
        
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        view = imgView
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.view.contentMode = .scaleAspectFit
            
            guard let weatherData = model else {
                self.view.image = UIImage(named: "cloud.sunny")
                return
            }
            
            switch weatherData.weather.code {
            case .thunderstorm:
                self.view.image = UIImage(named: "thunder")
                
            case .drizzle:
                self.view.image = UIImage(named: "rain")
//                self.view.contentMode = .scaleAspectFill
                
            case .rain:
                self.view.image = UIImage(named: "rain")
//                self.view.contentMode = .scaleAspectFill
                
            case .snow:
                self.view.image = UIImage(named: "rain")
//                self.view.contentMode = .scaleAspectFill
                
            case .atmosphere:
                self.view.image = UIImage(named: "atmosphere")
                self.view.contentMode = .scaleAspectFill
                
            case .clear:
                self.view.image = UIImage(named: "sun")
                
            case .clouds:
                self.view.image = UIImage(named: "cloud")  // TODO: prettify image
            }
        }
    }
}

class CentralDegreesComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "––º"
        lbl.font = UIFont(name: "Inter", size: 70)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "––º"
                return
            }
            
            self.view.text = "\(Int(weatherData.main.temperature.rounded()))º"
        }
    }
}

class CentralDescriptionComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "Unknown weather"
        lbl.font = UIFont(name: "Inter", size: 18)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "Unknown weather"
                return
            }
            
            self.view.text = weatherData.weather.title
        }
    }
}

class CentralSubscriptComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private var modelSubscribtion: AnyCancellable?
    
    init(listen modelPublisher: AnyPublisher<Model, Error>) {
        let lbl = UILabel()
        
        lbl.text = "Trying to update information..."
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let weatherData = model else {
                self.view.text = "Couldn't get the information"
                return
            }
            
            let description = weatherData.weather.description.capitalizingFirstLetter()
            let feelsLike = Int(weatherData.main.feelsLike.rounded())
            self.view.text = "\(description) | Feels like \(feelsLike)º"
        }
    }
}
