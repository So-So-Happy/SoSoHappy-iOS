//
//  Rx+UICollectionView.swift
//  SoSoHappy
//
//  Created by Sue on 10/11/23.
//

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UICollectionView {
    var deselectItem: Binder<Int> {
        return Binder(self.base) { collectionView, item in
            let indexPath = IndexPath(item: item, section: 0)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
