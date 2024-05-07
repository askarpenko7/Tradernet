//
//  SwipeableCollectionViewCell.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import SnapKit
import UIKit

class SwipeableCollectionViewCell: UICollectionViewCell {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()

    let visibleContainerView = UIView()
    let hiddenContainerView = UIView()

    weak var delegate: SwipeableCollectionViewCellDelegate?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestureRecognizer()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        scrollView.delegate = self
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(visibleContainerView)
        stackView.addArrangedSubview(hiddenContainerView)

        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(2)
        }
    }

    private func setupGestureRecognizer() {
        let visibleContainerTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(visibleContainerViewTapped)
        )
        visibleContainerView.addGestureRecognizer(visibleContainerTapGestureRecognizer)
    }

    @objc private func visibleContainerViewTapped() {
        delegate?.visibleContainerViewTapped(in: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = scrollView.frame.width
        }
    }

    func resetAction() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.scrollView.contentOffset.x = 0
        }
    }
}

extension SwipeableCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == scrollView.frame.width {
            delegate?.leftScrollAction(in: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.resetAction()
            }
        }
    }
}
