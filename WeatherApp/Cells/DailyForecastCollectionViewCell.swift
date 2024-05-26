//
//  DailyForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Denis Raiko on 9.05.24.
//

import UIKit

class DailyForecastCollectionViewCell: UICollectionViewCell {
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var minTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Bold", size: 15)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dayLabel, image, maxTempLabel, minTempLabel])
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.alignment = .center
        view.spacing = 8
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
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            image.widthAnchor.constraint(equalToConstant: 60),
            image.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with imageURL: URL, data: DailyWeather) {
        dayLabel.text = data.date
        loadImage(from: imageURL)
        maxTempLabel.text = "\(Int(data.maxTemp))°C"
        minTempLabel.text = "\(Int(data.minTemp))°C"
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

