//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/17/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var pin: Pin?

}
