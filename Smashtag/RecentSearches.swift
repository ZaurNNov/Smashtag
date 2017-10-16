//
//  RecentSearches.swift
//  Smashtag
//
//  Created by User on 16.10.2017.
//  Copyright © 2017 ZaurNNov. All rights reserved.
//

import Foundation

struct RecentSearches {
    private static let userDefaultsStandart = UserDefaults.standard
    private static let key = "RecentSearces"
    private static let limit = 100
    
    static var searches: [String] {
        return (userDefaultsStandart.object(forKey: key) as? [String]) ?? []
    }
    
    static func addRecents(_ term: String) {
        guard !term.isEmpty else {return}
        var array = searches.filter {term.caseInsensitiveCompare($0) != .orderedSame}
        array.insert(term, at: 0)
        while array.count > limit {
            array.removeLast()
        }
        userDefaultsStandart.set(array, forKey:key)
    }
    
    static func removeAtIndex(_ index: Int) {
        var currentSearches = (userDefaultsStandart.object(forKey: key) as? [String]) ?? []
        currentSearches.remove(at: index)
        userDefaultsStandart.set(currentSearches, forKey: key)
    }
    
}
