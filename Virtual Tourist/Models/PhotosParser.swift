//
//  PhotosParser.swift
//  Virtual Tourist
//
//  Created by Antonio on 12/27/17.
//  Copyright © 2017 Antônio Carlos. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
