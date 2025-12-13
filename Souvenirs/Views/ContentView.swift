//
//  ContentView.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memories: [Memory]
    
    @State private var showingAddMemory = false
    @State private var selectedTab = 0
    @State private var searchManager = SearchManager()
    @State private var showingFilters: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // List View Tab
            NavigationStack {
                Group {
                    if memories.isEmpty {
                        emptyStateView
                    } else {
                        
                        VStack(spacing: 0) {
                            
                            //searchbar
                            searchBar
                            
                            //Filter chips
                            if searchManager.searchText.isEmpty && searchManager.selectedLocation == "All Locations" && !searchManager.showOnlyWithAudio && searchManager.sortOption == .dateNewest {
                                
                                //NO ACTIVE Filters -> show nothing
                                
                            } else {
                                activeFiltersView
                                
                            } //if end
                            
                            listView
                            
                        } //inner vstack end
                        
                    } //if end
                } //group end
                .navigationTitle("Memories")
                .toolbar {
                    ToolbarItem (placement: .navigationBarLeading) {
                        
                        Button (action: { showingFilters = true}) {
                            
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            
                        } //button end
                        
                    } //toolbar item end
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        Button(action: { showingAddMemory = true }) {
                            Label("Add Memory", systemImage: "plus")
                            
                        } //button end
                        
                    } //tool bar item 2 end
                    
                } //toolbar end
                .sheet(isPresented: $showingFilters) {
                    FilterView(searchManager: searchManager, memories: memories)
                    
                } //sheet end
                
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(0)
            
            // Map View Tab
            NavigationStack {
                if memories.isEmpty {
                    emptyStateView
                } else {
                    Mapview()
                }
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingAddMemory) {
            AddMemoryView()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Memories Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first memory to get started")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddMemory = true }) {
                Label("Create Memory", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
    
    //MARK: SEARCH BAR
    private var searchBar: some View {
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search Memories ...", text: $searchManager.searchText)
                .textFieldStyle(.plain)
            
            if !searchManager.searchText.isEmpty {
                
                Button(action: {
                    searchManager.searchText = ""
                    
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                    
                } //button trailing closure end
                
            } //if end
            
        } //hstack end
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
        
    } //inner view end
    
    //MARK: ACTIVE FILTERS
    private var activeFiltersView: some View {
        
        ScrollView (.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                if !searchManager.searchText.isEmpty {
                    
                    FilterChip(
                        text: "Search: \(searchManager.searchText)",
                        onRemove: {searchManager.searchText = "" }
                    )
                    
                } //if end
                
                if searchManager.selectedLocation != "All Locations" {
                    
                    FilterChip(
                        text: searchManager.selectedLocation,
                        onRemove: { searchManager.selectedLocation = "All Locations"}
                    )
                    
                } //if end
                
                if searchManager.showOnlyWithAudio {
                    
                    FilterChip(
                        text: "Has Audio",
                        onRemove: { searchManager.showOnlyWithAudio = false }
                    )
                    
                } //if end
                
                if searchManager.sortOption != .dateNewest {
                    
                    FilterChip(
                        text: searchManager.sortOption.rawValue,
                        onRemove: { searchManager.sortOption = .dateNewest }
                    )
                    
                } //if end
                
                if searchManager.searchText.isEmpty == false || searchManager.selectedLocation != "All Locations" || searchManager.showOnlyWithAudio || searchManager.sortOption != .dateNewest {
                    
                    Button (action: {
                        searchManager.clearFilters()
                    }) {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                    }
                    
                } //if end
                
            } //hstack end
            .padding(.horizontal)
            
        } //scrollview end
        .padding(.bottom, 8)
        
    } //inner view end
    
    
    // MARK: - List View
    private var listView: some View {
        
        let filteredMemories = searchManager.filterAndSort(memories: memories)
        
        return Group {
            
            if filteredMemories.isEmpty {
                
                //No results view
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Memories Found!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Try adjusting your search or filters")
                        .foregroundColor(.gray)
                    
                    Button("Clear Filters") {
                        
                        searchManager.clearFilters()
                        
                    } //button end
                    .padding(.top)
                    
                } //vstack end
                .padding()
                
            } else {
                
                
                List {
                    ForEach(filteredMemories) { memory in
                        NavigationLink(destination: MemoryDetailView(memory: memory)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(memory.title)
                                        .font(.headline)
                                    
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Text(memory.locationName)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        
                                    } //inner hstack end
                                    
                                    Text(memory.content)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        Text(memory.createdDate, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        if memory.hasAudio {
                                            Image(systemName: "waveform")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            
                                        } //if end
                                        
                                    } //inner hstack 2 end
                                    
                                } //vstack end
                                
                                Spacer()
                                
                                //LIKE BUTTON SEPARATE FROM NAVIGATION LINK
                                Button(action: {
                                    toggleLike(for: memory)
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                        
                                        Text("\(memory.likesCount)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                    } //iner vstack end
                                    
                                } //BUTTON END
                                .buttonStyle(.plain)
                                
                            } //hstack end
                            .padding(.vertical)
                            
                        } //navigation link end
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                ShareManager.shared.shareMemoryAsImage(memory: memory)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                
                            } //button end
                            .tint(.blue)
                            
                        } //swipeaction end
                        
                    } //foreach end
                    .onDelete(perform: deleteMemories)
                    
                }//list end
                
            } //if end
            
        } //group end
        
        
    } //list view end
    
    private func deleteMemories(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(memories[index])
        }
    }
    
    //
    private func toggleLike(for memory: Memory) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            memory.likesCount += 1
        } //animation end
        
    } //func end
}

#Preview {
    ContentView()
        .modelContainer(for: Memory.self, inMemory: true)
}
