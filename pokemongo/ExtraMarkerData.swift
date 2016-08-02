//
//  ExtraMarkerData.swift
//  pokemongo
//
//  Created by Angel Lim on 7/16/16.
//  Copyright © 2016 Angel Lim. All rights reserved.
//

import Foundation


class ExtraMarkerData {
    var uniqueDatabaseID: String
    init(id: String) {
        self.uniqueDatabaseID = id
    }
    
    func getdbID() -> String {
        return self.uniqueDatabaseID
    }
}