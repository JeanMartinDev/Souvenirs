//
//  MemoryDetailView.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import SwiftUI
import MapKit

struct MemoryDetailView: View {
    let memory: Memory
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 20) {
                    //map section, if coordinates are available
                    if let latitude = memory.latitude,
                       let longitude = memory.longitude {
                        
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        ))) {
                            Annotation(memory.locationName, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                                
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                            } //annotation end
                            
                        } //inner map end
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                    } //if let end
                    
                    //LOCATION
                    VStack(alignment: .leading, spacing: 8) {
                        Label(memory.locationName, systemImage: "location.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(memory.createdDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if memory.isAnonymous {
                            Label("Posted anonymously", systemImage: "person.fill.questionmark")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                        } //inner if loop end
                        
                    } //inner vstack end
                    .padding(.horizontal)
                    
                    Divider()
                    
                    //CONTENT
                    VStack (alignment: .leading, spacing: 12) {
                        Text("Story")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(memory.content)
                            .font(.body)
                            .lineSpacing(4)
                        
                    } //inner vstack 2 end
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    //LIKES SECTION
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(memory.likesCount) likes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }//hstack end
                    .padding(.horizontal)
                    
                    Spacer()
                    
                }//vstack end
                .navigationBarTitle(memory.title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                            
                        } // button end
                        
                    }//tool bar item end
                }//tool bar end
                
            }//scrollview end
            
        }//navigation stack end
    } // body end
} //struct end

#Preview {
    let previewMemory = Memory(
        title: "Refugee camp",
        content: "I spent 1 month in an HCR-managed refugee camp outside of Matadi, DRC",
        locationName: "Matadi, DRC",
        latitude: -5.8167,
        longitude: 13.45)
    
    return MemoryDetailView(memory: previewMemory)
}
