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
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageUrl = photo.imageUrl!
        configImage(using: cell, photo: photo, cv: collectionView, index: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        configItemSelected(cell, atIndexPath: indexPath)
        updateBottomButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if photo.image == nil {
            if let imageUrl = photo.imageUrl {
                Client.shared().cancelDownload(imageUrl)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configItemSelected(_ photoViewCell: PhotoViewCell, atIndexPath indexPath: IndexPath) {
        
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
    
    private func configImage(using cell: PhotoViewCell, photo: Photo, cv: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: imageData))
        } else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicator.startAnimating()
                Client.shared().downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        self.performUIUpdatesOnMain {
                            cell.activityIndicator.stopAnimating()
                            self.showInfo(withTitle: "Error", withMessage: "Error while fetching image for URL: \(imageUrl)", action: nil)
                        }
                        return
                    } else if let data = data {
                        self.performUIUpdatesOnMain {
                            
                            if let newCell = cv.cellForItem(at: index) as? PhotoViewCell {
                                if newCell.imageUrl == imageUrl {
                                    newCell.imageView.image = UIImage(data: data)
                                    cell.activityIndicator.stopAnimating()
                                }
                            }
                            photo.image = NSData(data: data)
                            DispatchQueue.global(qos: .background).async {
                                self.save()
                            }
                        }
                    }
                }
            }
        }
    }
    
}
