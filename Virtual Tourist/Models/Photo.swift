//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/17/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    static let name = "Photo"
    
    convenience init(title: String, photoData: Data, forPin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photo.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.image = NSData(data: photoData)
            self.pin = forPin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
