//
//  SwipeableCollectionViewCellDelegate.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import UIKit

protocol SwipeableCollectionViewCellDelegate: AnyObject {
    func visibleContainerViewTapped(in cell: UICollectionViewCell)
    func leftScrollAction(in cell: UICollectionViewCell)
}
