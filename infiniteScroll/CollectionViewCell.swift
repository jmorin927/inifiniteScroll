//
//  CollectionViewCell.swift
//  infiniteScroll
//
//  Created by Jonathan Morin on 10/22/19.
//  Copyright © 2019 Jonathan Morin. All rights reserved.
//

import UIKit

// MARK: -

class CollectionViewCell: UICollectionViewCell {

    // MARK: - @IBOutlet

    @IBOutlet weak var label: UILabel!

    // MARK: - Internal Methods

    func configureCell(text: String,
                       color: UIColor) {
        label.text = text
        label.backgroundColor = color
        backgroundColor = color
    }

}
