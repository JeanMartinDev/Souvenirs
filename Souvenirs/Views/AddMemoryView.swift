//
//  AddMemoryView.swift
//  Souvenirs
//
//  Created by Jean Martin on 30/11/2025.
//

import SwiftUI
import SwiftData
import CoreLocation

struct AddMemoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //form fields
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var locationName: String = ""
    @State private var isAnonymous: Bool = false
    
    //form validation
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section(header: Text("Memory Details")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Location(ex: Matadi, DRC", text: $locationName)
                        .textInputAutocapitalization(.words)
                }//section 1 end
                
                Section(header: Text("Your Story")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                    
                } //section 2 end
                
                Section {
                    Toggle("Post Anonymously", isOn: $isAnonymous)
                    
                }//section 3 end
                
                Section {
                    Button(action: saveMemory) {
                        
                        HStack {
                            Spacer()
                            Text("Save Memory")
                                .fontWeight(.semibold)
                            Spacer()
                            
                        } //hstack end
                        
                    }//button end
                    .disabled(title.isEmpty || content.isEmpty || locationName.isEmpty)
                    
                }//section 4 end
                
            } //form end
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    } //button end
                    
                }//toolbar item 1 end
            }// toolbar end
            .alert("Cannot Save", isPresented: $showingAlert) {
                
                Button("OK", role: .cancel) {}
                
            } message: {
                Text(alertMessage)
            } //alert end
            
        }//navigation stack end
        
    } //body end
    
    //MARK: WE ADD FUNCTIONS BELOW
    private func saveMemory() {
        //validate input
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a title for your memory."
            showingAlert = true
            return
            
        } //guard statement 1 end
        
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please share your story!"
            showingAlert = true
            return
        } // //guard statement 2 end
        
        guard !locationName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a location!"
            showingAlert = true
            return
        }
        
        //create and save the memory
        let newMemory = Memory(
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            locationName: locationName.trimmingCharacters(in: .whitespaces),
            isAnonymous: isAnonymous)
        
        modelContext.insert(newMemory)
        
        //Geocode the location asynchronously
        task {
            if let coordinate = await LocationManager.shared.geocodeLocation(newMemory.locationName) {
                
                newMemory.latitude = coordinate.latitude
                newMemory.longitude = coordinate.longitude
                
            }
        } //task end
        
        //close the form
        dismiss()
        
    }//func end
} // struct end

#Preview {
    AddMemoryView()
        .modelContainer(for: Memory.self, inMemory: true)
}
