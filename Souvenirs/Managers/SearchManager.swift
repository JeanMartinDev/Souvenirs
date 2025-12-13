//
//  SearchManager.swift
//  Souvenirs
//
//  Created by Jean Martin on 11/12/2025.
//

import Foundation
import SwiftData

@Observable

class SearchManager {
    var searchText: String = ""
    var selectedLocation: String = "All Locations"
    var showOnlyWithAudio: Bool = false
    var sortOption: SortOption = .dateNewest
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
        case mostLiked = "Most Liked"
        case alphabetical = "A to Z"
        
    } //enum end
    
    //FILTER AND SEARCH MEMORIES BASED ON CURRENT SETTINGS
    func filterAndSort(memories: [Memory]) -> [Memory] {
        
        var filtered = memories
        
        //filter by search text
        if !searchText.isEmpty {
            
            filtered = filtered.filter { memory in
                memory.title.localizedCaseInsensitiveContains(searchText) || memory.content.localizedCaseInsensitiveContains(searchText) || memory.locationName.localizedCaseInsensitiveContains(searchText)
                
            } //loop end
            
        } //if end
        
        //filter by location
        if selectedLocation != "All Locations" {
            filtered = filtered.filter { $0.locationName == selectedLocation }
            
        } //if end
        
        //FILTER BY AUDIO
        if showOnlyWithAudio {
            filtered = filtered.filter { $0.hasAudio }
            
        } //if end
        
        //SORT OPTIONS
        switch sortOption {
        case .dateNewest:
            filtered.sort { $0.createdDate > $1.createdDate }
        case .dateOldest:
            filtered.sort { $0.createdDate < $1.createdDate }
        case .mostLiked:
            filtered.sort { $0.likesCount > $1.likesCount }
        case .alphabetical:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        } //switch end
            
        
        return filtered
        
    } //fund end
    
    //GET UNIQUE LOCATIONS FROM ALL MEMORIES
    func getUniqueLocations(from memories: [Memory]) -> [String] {
        
        let locations = Set(memories.map { $0.locationName })
        return ["All Locations"] + locations.sorted()
        
        
    } // func end
    
    //CLEAR ALL FILTERS
    func clearFilters() {
        
        searchText = ""
        selectedLocation = "All Locations"
        showOnlyWithAudio = false
        sortOption = .dateNewest
        
        
    } //func end
    
} //class end
