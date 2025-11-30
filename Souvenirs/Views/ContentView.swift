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

    var body: some View {
        TabView(selection: $selectedTab) {
            // List View Tab
            NavigationStack {
                Group {
                    if memories.isEmpty {
                        emptyStateView
                    } else {
                        listView
                    }
                }
                .navigationTitle("Memories")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddMemory = true }) {
                            Label("Add Memory", systemImage: "plus")
                        }
                    }
                }
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
    
    // MARK: - List View
    private var listView: some View {
        List {
            ForEach(memories) { memory in
                NavigationLink(destination: MemoryDetailView(memory: memory)) {
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
                        }
                        
                        Text(memory.content)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(memory.createdDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Text("\(memory.likesCount)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteMemories)
        }
    }

    private func deleteMemories(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(memories[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memory.self, inMemory: true)
}
