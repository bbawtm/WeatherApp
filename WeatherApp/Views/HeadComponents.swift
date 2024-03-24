//
//  HeadComponents.swift
//  WeatherApp
//
//  Created by Vadim Popov on 22.03.2024.
//

import UIKit
import Combine


class HeadDayDescriptionComponent4: Component4 {
    typealias Model = Any?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let lbl = UILabel()
        lbl.text = "Today, \(dateFormatter.string(from: Date.now))"
        lbl.font = UIFont(name: "Inter", size: 17)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
    }
    
    func requestUpdates(withModel model: Model) {
    }
}

class HeadLocationDescriptionComponent4: Component4 {
    typealias Model = Any?
    typealias ConcreteView = UILabel
    
    var model: Model = nil
    var view: ConcreteView
    
    private weak var locationModel = LocationModel.instance
    private var modelSubscribtion: AnyCancellable?
    
    init() {
        let lbl = UILabel()
        
        lbl.textAlignment = .center
        lbl.attributedText = Self.locationLabelAttributedText(string: "Updating...")
        lbl.font = UIFont(name: "Inter", size: 14)
        lbl.textColor = UIColor(red: 0.69921875, green: 0.6953125, blue: 0.71484375, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        view = lbl
        
        modelSubscribtion = locationModel?.updationPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] _ in
                self?.requestUpdates(withModel: nil)
            }
        )
    }
    
    func requestUpdates(withModel model: Model) {
        locationModel?.requestCurrentLocationRepresentation { [weak self] representation in
            guard let self else { return }
            self.view.attributedText = Self.locationLabelAttributedText(string: representation)
        }
    }
    
    private static func locationLabelAttributedText(string: String) -> NSAttributedString {
        let completeText = NSMutableAttributedString(string: "")
        
        if let mapPinImage = UIImage(named: "map.pin") {
            completeText.append(NSAttributedString(attachment: NSTextAttachment(image: mapPinImage)))
            completeText.append(NSAttributedString(string: " "))
        }
        
        let locationDescription = NSAttributedString(string: string)
        completeText.append(locationDescription)
        
        return completeText
    }
}

class HeadRefreshDescriptionComponent4: Component4 {
    typealias Model = Int
    typealias ConcreteView = UIImageView
    
    var model: Model = 0
    var view: ConcreteView
    private var modelSubscription: AnyCancellable?
    private let lock = DispatchSemaphore(value: 1)
    
    init(listen modelPublisher: AnyPublisher<Model, Error>?) {
        let image = UIImage(named: "arrow.clockwise")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        
        view = imageView
        
        modelSubscription = modelPublisher?.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] value in
                self?.requestUpdates(withModel: value)
            }
        )
    }
    
    private func rotateArrow(_ position: Int = 1) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
            self?.view.transform = CGAffineTransform(rotationAngle: CGFloat(position) * .pi)
            
        } completion: { [weak self] _ in
            if !(self?.view.isHidden ?? true) {
                self?.rotateArrow((position + 1) % 2)
            }
        }
    }
    
    func requestUpdates(withModel delta: Model) {
        lock.wait()
        model += delta
        let needsAnimation = model == 1 && delta == 1
        self.lock.signal()
        
        DispatchQueue.main.async { [weak self] in
            if let self {
                self.view.isHidden = self.model <= 0
                
                if needsAnimation {
                    self.rotateArrow()
                }
            }
        }
    }
}
