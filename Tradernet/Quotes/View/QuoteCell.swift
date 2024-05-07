//  QuoteCell.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 05.05.2024.
//

import SnapKit
import UIKit

class QuoteCell: SwipeableCollectionViewCell {
    static let reuseIdentifier = "QuoteCell"

    private lazy var tickerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .primaryText
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var nameAndExchangeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .secondaryText
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()

    private lazy var lastTradeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .primaryText
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var percentView = PercentView()

    private lazy var quoteLogoView = QuoteLogoView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with model: QuoteModel) {
        tickerLabel.text = model.ticker
        quoteLogoView.setTicker(model.ticker)
        percentView.update(
            with: model.percentageChangeFormatted,
            style: model.percentViewStyle,
            direction: model.percentageChangeDirection
        )
        nameAndExchangeLabel.text = model.nameAndExchangeFormatted
        lastTradeLabel.text = model.lastTradeFormatted
    }

    private func setupViews() {
        visibleContainerView.backgroundColor = .mainBackground
        let logoTickerStack = UIStackView(arrangedSubviews: [quoteLogoView, tickerLabel])
        logoTickerStack.axis = .horizontal
        logoTickerStack.distribution = .fill
        logoTickerStack.alignment = .center
        logoTickerStack.spacing = 8

        let leftStack = UIStackView(arrangedSubviews: [logoTickerStack, nameAndExchangeLabel])
        leftStack.axis = .vertical
        leftStack.distribution = .equalSpacing
        leftStack.spacing = 5
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        let rightStack = UIStackView(arrangedSubviews: [percentView, lastTradeLabel])
        rightStack.axis = .vertical
        rightStack.distribution = .equalSpacing
        rightStack.spacing = 7
        rightStack.alignment = .trailing
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        quoteLogoView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }

        visibleContainerView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let label = UILabel()
        label.text = LocalizedString.delete.localized
        label.textColor = .white

        hiddenContainerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        hiddenContainerView.backgroundColor = .red

        let divider = UIView()
        divider.backgroundColor = .supplementary

        visibleContainerView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(mainStack.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
