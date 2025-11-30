//
//  Mapview.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import SwiftUI
import MapKit
import SwiftData

struct Mapview: View {
    @Query private var memories: [Memory]
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedMemory: Memory?
    
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedMemory) {
            
            ForEach(memories) { memory in
                if let latitude = memory.latitude,
                   let longitude = memory.longitude {
                    Annotation(memory.title, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                        
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Text(memory.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(4)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(4)
                            
                        }//vstack end
                        
                    } //Annotation end
                    .tag(memory)
                    
                }//if let end
                
            }//for each end
            
        }//map end
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }//map controls end
        .sheet(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory)
        } //sheet end
    }// body end
}//struct end

#Preview {
    Mapview()
        .modelContainer(for: Memory.self, inMemory: true)
}
