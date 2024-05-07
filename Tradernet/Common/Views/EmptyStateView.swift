//
//  EmptyStateView.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 07.05.2024.
//

import UIKit

import UIKit

class EmptyStateView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "folder.fill.badge.plus")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString.emptyStateMessage.localized
        label.textColor = .secondaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizedString.emptyStateButton.localized, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    private let recommendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizedString.emptyStateRecommendedButton.localized, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(addButton)
        addSubview(recommendButton)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-70) // Adjusted for spacing
            make.width.height.equalTo(100)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }

        recommendButton.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    func setAddButtonAction(target: Any?, action: Selector) {
        addButton.addTarget(target, action: action, for: .touchUpInside)
    }

    func setRecommendButtonAction(target: Any?, action: Selector) {
        recommendButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
