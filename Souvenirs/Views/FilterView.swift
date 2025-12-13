//
//  FilterView.swift
//  Souvenirs
//
//  Created by Jean Martin on 12/12/2025.
//

import SwiftUI

struct FilterView: View {
    @Bindable var searchManager: SearchManager
    let memories: [Memory]
    @Environment (\.dismiss) private var dismiss
    
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                Section(header: Text("Location")) {
                    
                    Picker("Location", selection: $searchManager.selectedLocation) {
                        
                        ForEach(searchManager.getUniqueLocations(from: memories), id: \.self) { location in
                            
                            Text(location).tag(location)
                        } //for each end
                        
                    } //picker end
                    .pickerStyle(.menu)
                    
                } // section end
                
                Section(header: Text("Media")) {
                    
                    Toggle("Only Show Memories With Audio", isOn: $searchManager.showOnlyWithAudio)
                    
                }//section end
                
                Section(header: Text("Sort By")) {
                    
                    Picker("Sort", selection: $searchManager.sortOption) {
                        
                        ForEach(SearchManager.SortOption.allCases, id: \.self) { option in
                            
                            Text(option.rawValue).tag(option)
                            
                        } //foreach end
                        
                    } //picker end
                    .pickerStyle(.menu)
                    
                } //section end
                
                Section {
                    
                    Button("Clear All Filters") {
                        searchManager.clearFilters()
                        
                    } //button end
                    .foregroundColor(.red)
                    
                } //section end
                
            } //form end
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Done") {
                        dismiss()
                        
                    } //button end
                    
                } //toolbar item end
                
            } //toolbar end
            
        }//navigation stack end
    } //body end
} //struct end

#Preview {
    let searchManager = SearchManager()
    
    // Create sample memories for preview
    let sampleMemories = [
        Memory(
            title: "Refugee Camp",
            content: "My time in the camp...",
            locationName: "Matadi, DRC"
        ),
        Memory(
            title: "New Beginning",
            content: "Arriving in a new country...",
            locationName: "Paris, France"
        ),
        Memory(
            title: "Family Reunion",
            content: "Seeing family again...",
            locationName: "London, UK"
        )
    ]
    
    return FilterView(searchManager: searchManager, memories: sampleMemories)
}
