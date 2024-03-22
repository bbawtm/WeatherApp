//
//  SearchVC.swift
//  WeatherApp
//
//  Created by Vadim Popov on 20.03.2024.
//

import UIKit


class SearchVC: UIViewController {
    
    private weak var model = ForecastModel.instance
    
    public func preparedForTabBar() -> Self {
        let icon = UIImage(systemName: "magnifyingglass")
        let colorSelected = UIColor(red: 0.984375, green: 0.7578125, blue: 0.359375, alpha: 1)
        let colorNonSelected = UIColor.white
        
        tabBarItem = UITabBarItem(
            title: "Search",
            image: icon?.withTintColor(colorNonSelected, renderingMode: .alwaysOriginal),
            selectedImage: icon?.withTintColor(colorSelected, renderingMode: .alwaysOriginal)
        )
        
        UITabBar.appearance().tintColor = colorSelected
        UITabBar.appearance().unselectedItemTintColor = colorNonSelected
        
        return self
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
    }
    
}
