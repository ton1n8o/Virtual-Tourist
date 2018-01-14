//
//  PhotoAlbumViewController+Extension.swift
//  Virtual Tourist
//
//  Created by Antonio on 1/1/18.
//  Copyright © 2018 Antônio Carlos. All rights reserved.
//

import UIKit
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}

// MARK: - UICollectionView DataSource & Delegate

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.identifier, for: indexPath) as! PhotoViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        configImage(using: cell, photo: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        configureCell(cell, atIndexPath: indexPath)
        updateBottomButton()
    }
    
    // MARK: - Helpers
    
    private func configureCell(_ photoViewCell: PhotoViewCell, atIndexPath indexPath: IndexPath) {
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        if selectedIndexes.contains(indexPath) {
            photoViewCell.imageView.alpha = 0.2
        } else {
            photoViewCell.imageView.alpha = 1.0
        }
    }
    
    private func configImage(using cell: PhotoViewCell, photo: Photo) {
        if photo.image == nil {
            cell.activityIndicator.startAnimating()
            if let imageUrl = photo.imageUrl {
                Client.shared().downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let data = data {
                        self.performUIUpdatesOnMain {
                            cell.imageView.image = UIImage(data: data)
                            photo.image = NSData(data: data)
                            self.save()
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        } else {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: photo.image!))
        }
    }
    
}
