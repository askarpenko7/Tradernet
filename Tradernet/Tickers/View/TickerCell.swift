//
//  TickerCell.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import UIKit

class TickerCell: UITableViewCell {
    static let reuseIdentifier = "TickerCell"

    private lazy var tickerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .primaryText
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var quoteLogoView = QuoteLogoView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ ticker: String) {
        tickerLabel.text = ticker
        quoteLogoView.setTicker(ticker)
    }

    private func setupViews() {
        let logoTickerStack = UIStackView(arrangedSubviews: [quoteLogoView, tickerLabel])
        logoTickerStack.axis = .horizontal
        logoTickerStack.distribution = .fill
        logoTickerStack.alignment = .center
        logoTickerStack.spacing = 8

        contentView.addSubview(logoTickerStack)

        quoteLogoView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }

        logoTickerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }
}
