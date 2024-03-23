//
//  TemperatureChartComponent4.swift
//  WeatherApp
//
//  Created by Вадим Попов on 23.03.2024.
//

import UIKit
import Combine


class ChartComponent4: Component4 {
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
