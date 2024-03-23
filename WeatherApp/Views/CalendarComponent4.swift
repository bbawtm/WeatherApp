//
//  CalendarComponent4.swift
//  WeatherApp
//
//  Created by Vadim Popov on 23.03.2024.
//

import UIKit
import Combine


class CalendarTableViewCell: UITableViewCell {
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter", size: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightImageView)
        contentView.addSubview(rightLabel)
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            rightImageView.trailingAnchor.constraint(equalTo: rightLabel.leadingAnchor, constant: -8),
            rightImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 8),
            rightImageView.widthAnchor.constraint(equalToConstant: 40),
            rightImageView.heightAnchor.constraint(equalToConstant: 40),
            
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


private class CalendarTable: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let days: [Date]
    var lastFetchedModel: [WeatherData]?
    var subscriber: AnyCancellable?
    
    init(listen modelPublisher: CurrentValueSubject<[WeatherData]?, Error>, reloadDataClosure: @escaping () -> Void) {
        let currentDayDate = Self.dayDate(date: .now)
        days = (1...5).map {
            currentDayDate.addingTimeInterval(TimeInterval($0 * 24 * 3600))
        }
        
        lastFetchedModel = modelPublisher.value
        super.init()
        
        subscriber = modelPublisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] weatherDataList in
                self?.lastFetchedModel = weatherDataList
                reloadDataClosure()
            }
        )
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDate = days[indexPath.item]
        
        // Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd EEEE"
        
        let dateText = dateFormatter.string(from: currentCellDate)
        
        // Degrees
        
        let dayRecords = lastFetchedModel?.filter { Self.dayDate(date: $0.date) == currentCellDate }
        let maxValue = dayRecords?.max(by: { $0.main.temperature < $1.main.temperature })?.main.temperature.rounded()
        let minValue = dayRecords?.min(by: { $0.main.temperature < $1.main.temperature })?.main.temperature.rounded()
        
        let degreesText: String
        
        if let maxValue, let minValue {
            degreesText = "\(Int(maxValue))° / \(Int(minValue))°"
            
        } else {
            degreesText = "––° / ––°"
        }
        
        // Cell
        
        let cell = CalendarTableViewCell()
        cell.leftLabel.text = dateText
        cell.rightLabel.text = degreesText
        cell.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        cell.selectionStyle = .none
        
        if indexPath.item == 4 {
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width + 1, bottom: 0, right: 0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    private static func dayDate(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
}


class CalendarComponent4: Component4 {
    typealias Model = [WeatherData]?
    typealias ConcreteView = UIView
    
    var model: Model = nil
    var view: ConcreteView
    private let tableDelegate: CalendarTable
    
    init(listen modelPublisher: CurrentValueSubject<Model, Error>) {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Inter", size: 18)
        titleLabel.textColor = .white
        titleLabel.text = "Week forecast"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.042, green: 0.047, blue: 0.119, alpha: 1)
        
        tableDelegate = CalendarTable(listen: modelPublisher) { [weak tableView] in
            DispatchQueue.main.async { [weak tableView] in
                tableView?.reloadData()
            }
        }
        
        tableView.delegate = tableDelegate
        tableView.dataSource = tableDelegate
        
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -27),
            tableView.heightAnchor.constraint(equalToConstant: 5*40),
        ])
    }
    
    func requestUpdates(withModel model: Model) {
    }
}
