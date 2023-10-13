//
//  my_models.swift
//  howtodj
//
//  Created by Paul Crews on 10/14/23.
//

import Foundation
import SwiftData

@Model
class Song {
    @Attribute(.unique) var id  : String = UUID().uuidString
    var name                    : String
    var artist                  : String
    var bpm                     : String
    var key                     : String
    var favorite                : String
    
    init(name: String, artist: String,bpm: String, key: String, favorite: String) {
        self.name       = name
        self.artist     = artist
        self.bpm        = bpm
        self.key        = key
        self.favorite   = favorite
    }
}

extension Song:Identifiable{}
extension Song:Hashable{
    static func == (lhs: Song, rhs: Song) -> Bool {
       let res = lhs.id.compare(rhs.id) == .orderedSame
        
        return res
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(artist)
        hasher.combine(bpm)
        hasher.combine(key)
        hasher.combine(favorite)
    }
}
