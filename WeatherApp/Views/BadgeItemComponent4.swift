//
//  BadgeItemComponent4.swift
//  WeatherApp
//
//  Created by Vadim Popov on 22.03.2024.
//

import UIKit
import Combine


class BadgeItemComponent4: Component4 {
    typealias Model = WeatherData?
    typealias ConcreteView = UIView
    
    var model: Model = nil
    var view: ConcreteView
    private var valueLabel: UILabel
    
    private var defaultValue: String
    private var valueGetter: (Model) -> String
    private var modelSubscribtion: AnyCancellable?
    
    init(
        imageName: String,
        titleText: String,
        defaultValue: String,
        valueGetter: @escaping (Model) -> String,
        listen modelPublisher: AnyPublisher<Model, Error>
    ) {
        self.defaultValue = defaultValue
        self.valueGetter = valueGetter
        
        let icon = UIImageView(image: UIImage(named: imageName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = titleText
        title.font = UIFont(name: "Inter", size: 16)
        title.textColor = .white
        
        let titleContainer = UIView()
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addSubview(icon)
        titleContainer.addSubview(title)
        
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = defaultValue
        valueLabel.font = UIFont(name: "Inter", size: 14)
        valueLabel.textColor = .white
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(titleContainer)
        content.addSubview(valueLabel)
        
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = UIColor(red: 0.2578125, green: 0.2578125, blue: 0.30859375, alpha: 1)
        badge.layer.cornerRadius = 12
        badge.addSubview(content)
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor, constant: -2),
            icon.leftAnchor.constraint(equalTo: titleContainer.leftAnchor),
            
            title.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10),
            title.rightAnchor.constraint(equalTo: titleContainer.rightAnchor),
            
            titleContainer.topAnchor.constraint(equalTo: content.topAnchor),
            titleContainer.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 20),
            valueLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            
            content.topAnchor.constraint(equalTo: badge.topAnchor, constant: 30),
            content.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -22),
            content.leftAnchor.constraint(equalTo: badge.leftAnchor, constant: 22),
            content.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -20),
        ])
        
        view = badge
        
        modelSubscribtion = modelPublisher.sink { _ in } receiveValue: { [weak self] weatherData in
            self?.requestUpdates(withModel: weatherData)
        }
    }
    
    func requestUpdates(withModel model: Model) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.valueLabel.text = self.valueGetter(model)
        }
    }
}
