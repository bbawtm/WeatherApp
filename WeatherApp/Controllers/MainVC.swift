//
//  MainVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit
import CoreLocation
import Combine


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

class MainVC: UIViewController {
    
    private weak var forecastModel = ForecastModel.instance
    private weak var locationModel = LocationModel.instance
    
    private var locationSubscriber: AnyCancellable?
    private var momentumForecastSubscriber: AnyCancellable?
    private var longTermForecastSubscriber: AnyCancellable?
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "cloud.fill")
        tabBarItem = UITabBarItem(
            title: "",
            image: icon?.withTintColor(.white, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1), renderingMode: .alwaysOriginal)
        )
        
        return self
    }
    
    private let dayDescriptionLabel: UILabel = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let lbl = UILabel()
        lbl.text = "Today, \(dateFormatter.string(from: Date.now))"
        lbl.font = UIFont(name: "Inter", size: 17)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    private func locationLabelAttributedText(string: String) -> NSAttributedString {
        let completeText = NSMutableAttributedString(string: "")
        
        if let mapPinImage = UIImage(named: "map.pin") {
            completeText.append(NSAttributedString(attachment: NSTextAttachment(image: mapPinImage)))
            completeText.append(NSAttributedString(string: " "))
        }
        
        let locationDescription = NSAttributedString(string: string)
        completeText.append(locationDescription)
        
        return completeText
    }
    
    private var locationLabelSubscriber: AnyCancellable? = nil
    private lazy var locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.attributedText = locationLabelAttributedText(string: "Updating...")
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        locationLabelSubscriber = locationModel?.updationPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self, weak lbl] _ in
                self?.locationModel?.requestCurrentLocationRepresentation { [weak self, weak lbl] representation in
                    guard let self, let lbl else { return }
                    lbl.attributedText = self.locationLabelAttributedText(string: representation)
                }
            }
        )
        
        return lbl
    }()
    
    private lazy var headingContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dayDescriptionLabel)
        container.addSubview(locationLabel)
        return container
    }()
    
    private let centralImage: UIImageView = {
        let image = UIImage(named: "cloud.sun")
        
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    private let centralDegrees: UILabel = {
        let lbl = UILabel()
        lbl.text = "––º"
        lbl.font = UIFont(name: "Inter", size: 70)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let centralDescription: UILabel = {
        let lbl = UILabel()
        lbl.text = "Unknown weather"
        lbl.font = UIFont(name: "Inter", size: 18)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let centralSubscript: UILabel = {
        let lbl = UILabel()
        lbl.text = "Trying to update information..."
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var centralContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(centralImage)
        container.addSubview(centralDegrees)
        container.addSubview(centralDescription)
        container.addSubview(centralSubscript)
        return container
    }()
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            // Heading
            dayDescriptionLabel.topAnchor.constraint(equalTo: headingContainer.topAnchor),
            dayDescriptionLabel.leftAnchor.constraint(equalTo: headingContainer.leftAnchor),
            
            locationLabel.topAnchor.constraint(equalTo: dayDescriptionLabel.bottomAnchor, constant: 7),
            locationLabel.leftAnchor.constraint(equalTo: headingContainer.leftAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: headingContainer.bottomAnchor),
            
            headingContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headingContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            
            // Central
            centralImage.topAnchor.constraint(equalTo: centralContainer.topAnchor),
            centralImage.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            centralImage.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            centralImage.heightAnchor.constraint(equalToConstant: 100),
            
            centralDegrees.topAnchor.constraint(equalTo: centralImage.bottomAnchor, constant: 10),
            centralDegrees.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralDescription.topAnchor.constraint(equalTo: centralDegrees.bottomAnchor),
            centralDescription.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            
            centralSubscript.topAnchor.constraint(equalTo: centralDescription.bottomAnchor, constant: 5),
            centralSubscript.centerXAnchor.constraint(equalTo: centralContainer.centerXAnchor),
            centralSubscript.bottomAnchor.constraint(equalTo: centralContainer.bottomAnchor),
            
            centralContainer.topAnchor.constraint(equalTo: headingContainer.bottomAnchor, constant: 50),
            centralContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    private func updateContent(forCoordinate coordinate: CLLocationCoordinate2D) {
        let momentumForecastPublisher = forecastModel?.momentumForecast(forCoordinate: coordinate)
        
        let momentumForecastUpdationClosure = { [weak self] (weatherData: WeatherData?) in
            guard let weatherData else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                self.centralDegrees.text = "\(Int(weatherData.main.temperature.rounded()))º"
                self.centralDescription.text = weatherData.weather.title
                self.centralSubscript.text = weatherData.weather.description.capitalizingFirstLetter()
            }
        }
        momentumForecastUpdationClosure(momentumForecastPublisher?.value)
        
        momentumForecastSubscriber = momentumForecastPublisher?.sink(
            receiveCompletion: { _ in },
            receiveValue: momentumForecastUpdationClosure
        )
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        
        view.addSubview(headingContainer)
        view.addSubview(centralContainer)
        activateConstraints()
        
        locationModel?.requestAppropriateAuthorization()
        
        locationSubscriber = locationModel?.updationPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] coordinate in
                if let coordinate {
                    self?.updateContent(forCoordinate: coordinate)
                }
            }
        )
    }
    
}
