//
//  PriceView.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import SnapKit
import UIKit

final class PercentView: UIView {
    private var style: Style = .neutral

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryText
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with percentageChange: String, style: Style, direction: QuoteModel.PercentageChangeDirection) {
        label.text = percentageChange
        self.style = style
        updateStyle()
        applyPercentageChanges(for: direction)
    }

    private func setupView() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        }
        backgroundColor = .none
        layer.cornerRadius = 4
    }

    private func updateStyle() {
        backgroundColor = .none
        switch style {
        case .neutral:
            label.textColor = .secondaryText
        case .positive:
            label.textColor = .positiveText
        case .negative:
            label.textColor = .negativeText
        }
    }

    private func applyPercentageChanges(for direction: QuoteModel.PercentageChangeDirection) {
        label.textColor = .white
        switch direction {
        case .none:
            updateStyle()
        case .up:
            backgroundColor = .positive
        case .down:
            backgroundColor = .negative
        }
    }
}

extension PercentView {
    enum Style {
        case neutral
        case positive
        case negative
    }
}
