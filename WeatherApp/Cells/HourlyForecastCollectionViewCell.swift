//
//  HourlyForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Denis Raiko on 9.05.24.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica Neue Bold", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [timeLabel, image, tempLabel])
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .center
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with imageURL: URL, data: HourlyWeather) {
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Предполагаем, что время приходит в этом формате
                if let date = dateFormatter.date(from: data.time) {
                    dateFormatter.dateFormat = "HH:mm"
                    timeLabel.text = dateFormatter.string(from: date)
                } else {
                    timeLabel.text = data.time // На случай, если формат неверный
                }
        loadImage(from: imageURL)
        tempLabel.text = "\(Int(data.temp))°C"
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self, let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.image.image = image
                } else {
                    print("Failed to create image from data")
                }
            }
        }.resume()
    }
}
