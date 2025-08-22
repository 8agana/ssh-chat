//
//  Item.swift
//  ssh-chat
//
//  Created by Samuel Atagana on 8/22/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
