//
//  Component4.swift
//  WeatherApp
//
//  Created by Vadim Popov on 22.03.2024.
//

import UIKit


protocol Component4 {
    associatedtype Model
    associatedtype ConcreteView
    
    var view: ConcreteView { get }
    var model: Model { get }
    
    func requestUpdates(withModel model: Model)
}
