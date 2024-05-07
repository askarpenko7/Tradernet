//
//  TickersViewController.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import SnapKit
import UIKit

final class TickersViewController: UIViewController {
    private var viewModel: TickersViewModelContract
    private let tableView = UITableView()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .secondaryText
        indicator.startAnimating()
        indicator.isHidden = true
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: TickersViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.view = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.fetchTickers()
    }

    private func setupViews() {
        title = LocalizedString.tickers.localized
        view.backgroundColor = .mainBackground
        setupActivityIndicator()
        setupTableView()
        setupCloseButton()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TickerCell.self, forCellReuseIdentifier: TickerCell.reuseIdentifier)
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(named: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeViewController)
        )
        navigationItem.rightBarButtonItem = closeButton
    }

    @objc private func closeViewController() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TickersViewContract

extension TickersViewController: TickersViewContract {
    func showTickers(_ tickers: [String]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.hideLoadingIndicator()
        }
    }

    func showLoadingIndicator() {
        tableView.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        tableView.isHidden = false
    }

    func showError(message: String) {
        let toast = ToastView(message: message)
        toast.show(in: self)
    }
}

// MARK: - UITableViewDataSource

extension TickersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tickers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TickerCell.reuseIdentifier,
            for: indexPath
        ) as? TickerCell
        else { fatalError() }
        cell.update(viewModel.tickers[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TickersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.saveTicker(at: indexPath.row)
        closeViewController()
    }
}
