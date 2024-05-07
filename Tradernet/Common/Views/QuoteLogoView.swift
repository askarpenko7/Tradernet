//
//  QuoteLogoView.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import SnapKit
import UIKit

class QuoteLogoView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true

        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.backgroundColor = .logoBackground
        label.textColor = .logoText
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var urlString = "https://tradernet.com/logos/get-logo-by-ticker?ticker="

    // Image cache dictionary or use NSCache for better memory management
    static let imageCache = NSCache<NSString, UIImage>()

    private var ticker: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.layer.cornerRadius = frame.size.width / 2
    }

    func setTicker(_ ticker: String) {
        if self.ticker != ticker {
            self.ticker = ticker
            setupPlaceholder()
            loadImage()
        }
    }

    private func setupViews() {
        addSubview(imageView)
        addSubview(placeholderLabel)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupPlaceholder() {
        guard let ticker = ticker else { return }
        let firstLetter = String(ticker.prefix(1))
        placeholderLabel.text = firstLetter
        placeholderLabel.isHidden = false
    }

    private func loadImage() {
        imageView.isHidden = true
        guard let ticker = ticker else { return }
        
        let url = URL(string: urlString.appending(ticker.lowercased()))
        
        guard let url = url else {
            placeholderLabel.isHidden = false
            return
        }

        if let cachedImage = QuoteLogoView.imageCache.object(forKey: url.absoluteString as NSString) {
            imageView.image = cachedImage
            imageView.isHidden = false
            placeholderLabel.isHidden = true
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, data.count > 1000, error == nil else { return }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    QuoteLogoView.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    self.imageView.image = image
                    self.imageView.isHidden = false
                    self.placeholderLabel.isHidden = true
                } else {
                    self.placeholderLabel.isHidden = false
                }
            }
        }.resume()
    }
}
