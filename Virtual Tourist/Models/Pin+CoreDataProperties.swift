//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/17/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: Photo?

}
