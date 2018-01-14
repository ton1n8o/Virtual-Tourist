//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Antonio on 1/13/18.
//  Copyright © 2018 Antônio Carlos. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
