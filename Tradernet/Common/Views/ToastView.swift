//
//  ToastView.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import SnapKit
import UIKit

class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .toastText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    init(message: String) {
        super.init(frame: .zero)
        backgroundColor = .toastBackground
        layer.cornerRadius = 10
        clipsToBounds = true
        messageLabel.text = message
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    func show(in viewController: UIViewController, duration: TimeInterval = 3.0) {
        guard let navBar = viewController.navigationController?.navigationBar else {
            viewController.view.addSubview(self)
            snp.makeConstraints { make in
                make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top).offset(10)
                make.centerX.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().offset(10)
                make.trailing.lessThanOrEqualToSuperview().offset(-10)
            }
            return
        }

        viewController.view.addSubview(self)
        snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
}
