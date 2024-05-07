//
//  QuotesViewContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 05.05.2024.
//

import UIKit

protocol QuotesViewContract: AnyObject {
    func showLoading()
    func hideLoading()
    func insertRowAt(_ indexPath: IndexPath?)
    func deleteRowAt(_ indexPath: IndexPath?)
    func reloadRowAt(_ indexPath: IndexPath?)
    func moveRow(at indexPath: IndexPath?, to newIndexPath: IndexPath?)
    func showToast(with message: String)
}
