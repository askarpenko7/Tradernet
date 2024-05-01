//
//  QuotesViewController.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 29.04.2024.
//

import SnapKit
import UIKit

class QuotesViewController: UIViewController {
    override func loadView() {
        super.loadView()

        let container = UIView()
        container.backgroundColor = .lightGray
        let label = UILabel()
        label.text = "Hey you"

        container.addSubview(label)

        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        view = container
    }
}
