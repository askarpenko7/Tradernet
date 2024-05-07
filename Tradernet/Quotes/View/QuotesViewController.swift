//
//  QuotesViewController.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 29.04.2024.
//

import SnapKit
import UIKit

final class QuotesViewController: UIViewController {
    private var collectionView: UICollectionView!
    private let viewModel: QuotesViewModelContract
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .secondaryText
        indicator.startAnimating()
        indicator.isHidden = true
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private lazy var emptyStateView = EmptyStateView()

    // MARK: - Inits

    init(viewModel: QuotesViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.notifyViewModel(with: .viewDidDisappear)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.notifyViewModel(with: .viewDidLoad)
    }

    // MARK: Private functions

    private func setupViews() {
        setupNavigationBar()
        view.backgroundColor = .mainBackground
        view.addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        setupCollectionView()
        setupEmptyState()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(QuoteCell.self, forCellWithReuseIdentifier: QuoteCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .mainBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        title = LocalizedString.quotes.localized
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupEmptyState() {
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyStateView.setAddButtonAction(target: self, action: #selector(addButtonTapped))
        emptyStateView.setRecommendButtonAction(target: self, action: #selector(recommendButtonTapped))
    }

    private func confirmDeletion(forItemAt indexPath: IndexPath) {
        let alert = UIAlertController(
            title: LocalizedString.deleteQuoteAlertTitle.localized,
            message: LocalizedString.deleteQuoteAlertMessage.localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LocalizedString.delete.localized, style: .destructive, handler: { [weak self] _ in
            self?.deleteQuote(at: indexPath)
        }))
        present(alert, animated: true)
    }

    private func deleteQuote(at indexPath: IndexPath) {
        viewModel.deleteQuote(at: indexPath)
    }

    @objc private func addButtonTapped() {
       presentTickerList()
    }
    
    @objc private func recommendButtonTapped() {
        viewModel.addRecommendedQuotes()
        
    }
    
    private func presentTickerList() {
        let networkManager = TickerManager()
        let repository = TickerRepository(networkManager: networkManager, quotesRepository: viewModel.repository)
        let viewModel = TickersViewModel(repository: repository)
        let controller = TickersViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true)
    }
}

// MARK: - Contract

extension QuotesViewController: QuotesViewContract {
    func insertRowAt(_ indexPath: IndexPath?) {
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }

    func deleteRowAt(_ indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        collectionView.deleteItems(at: [indexPath])
    }

    func reloadRowAt(_ indexPath: IndexPath?) {
        UIView.performWithoutAnimation {
            guard let indexPath = indexPath else { return }
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func moveRow(at indexPath: IndexPath?, to newIndexPath: IndexPath?) {
        guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
        collectionView.moveItem(at: indexPath, to: newIndexPath)
    }

    func showLoading() {
        collectionView?.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }

    func hideLoading() {
        collectionView?.isHidden = false
        loadingIndicator.stopAnimating()
    }

    func showToast(with message: String) {
        let toast = ToastView(message: message)
        toast.show(in: self)
    }
    
    func showStateView() {
        hideLoading()
        collectionView.isHidden = true
        emptyStateView.isHidden = false
    }
    
    func hideStateView() {
        collectionView.isHidden = false
        emptyStateView.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource

extension QuotesViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: QuoteCell.reuseIdentifier,
            for: indexPath
        ) as? QuoteCell
        else { fatalError() }
        if let quote = viewModel.quote(at: indexPath) {
            cell.update(with: quote)
        }

        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfQuotes
    }
}

// MARK: - UICollectionViewDelegate

extension QuotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 63)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

extension QuotesViewController: SwipeableCollectionViewCellDelegate {
    func visibleContainerViewTapped(in cell: UICollectionViewCell) {
        // do nothing
    }

    func leftScrollAction(in cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        confirmDeletion(forItemAt: indexPath)
    }
}
