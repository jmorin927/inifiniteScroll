//
//  ViewController.swift
//  infiniteScroll
//
//  Created by Jonathan Morin on 10/21/19.
//  Copyright © 2019 Jonathan Morin. All rights reserved.
//

import UIKit

// MARK: - Types -

private struct CollectionViewContent {
    var text: String
    var color: UIColor
}

// MARK: -

class ViewController: UIViewController {

    // MARK: - @IBOutlet

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
        }
    }


    // MARK: - Internal Properties

    var infiniteScrollCollectionViewProcessor: HorizontalInfiniteScrollCollectionViewProcessor?

    // MARK: - Private Properties

    private var collectionViewContentArray: [CollectionViewContent] = []

    // MARK: - Deinit

    deinit {
        infiniteScrollCollectionViewProcessor?.destroy()
    }

    // MARK: - UICollectionViewDelegate - Method Overrides

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 108, height: 108)
    }

}

// MARK: - Life Cycle

extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createContent()
        createHorizontalInfiniteScrollCollectionViewProcessor()
    }

}

// MARK: - Private Methods

extension ViewController {

    private func createHorizontalInfiniteScrollCollectionViewProcessor() {
        infiniteScrollCollectionViewProcessor = HorizontalInfiniteScrollCollectionViewProcessor(collectionView: collectionView)
        infiniteScrollCollectionViewProcessor?.moveDelta = 0.25
        infiniteScrollCollectionViewProcessor?.scrollDirection = .left
        infiniteScrollCollectionViewProcessor?.collectionViewCellSize = CGSize(width: 108, height: 108)
        infiniteScrollCollectionViewProcessor?.collectionViewMinSpacing = 10.0
        infiniteScrollCollectionViewProcessor?.collectionView?.delegate = infiniteScrollCollectionViewProcessor

        infiniteScrollCollectionViewProcessor?.collectionViewRotateContentCallback = { [weak self] in
            guard let self = self,
                let scrollDirection = self.infiniteScrollCollectionViewProcessor?.scrollDirection else {
                return
            }
            switch scrollDirection {
            case .right:
                let last = self.collectionViewContentArray.removeLast()
                self.collectionViewContentArray.insert(last, at: 0)
            case .left:
                let first = self.collectionViewContentArray.removeFirst()
                self.collectionViewContentArray.append(first)
            }
            self.collectionView.reloadData()
        }

        infiniteScrollCollectionViewProcessor?.collectionViewSelectContentCallback = { [weak self] (indexPath) in
            guard let self = self else {
                return
            }
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                let alertController = UIAlertController(
                    title: nil,
                    message: "You selected '\(cell.label.text ?? "")'",
                    preferredStyle: .alert)
                alertController.addAction(
                    UIAlertAction(
                        title: "Done",
                        style: .default,
                        handler: { (action) in
                            self.infiniteScrollCollectionViewProcessor?.resumeProcessor()
                        }
                    )
                )
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.infiniteScrollCollectionViewProcessor?.resumeProcessor()
            }
        }
    }

    private func createContent() {
        let names: [String] = [
            "Apple",
            "Google",
            "Amazon",
            "S & P 500",
            "Dow Jones",
            "Nasdaq",
            "Oil",
            "Gold",
            "US Bonds"
        ]
        
        for i in 0..<names.count {
            let content = CollectionViewContent(text: names[i],
                                                color: UIColor.white)
            collectionViewContentArray.append(content)
        }
    }

}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewContentArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        let content = collectionViewContentArray[indexPath.row]
        cell.configureCell(text: content.text,
                           color: content.color)
        return cell
    }

}
