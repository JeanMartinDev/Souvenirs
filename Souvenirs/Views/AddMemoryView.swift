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
    
    //Audio
    @State private var showAudioRecorder = false
    @State private var recordedAudioURL: URL?
    @State private var audioManager = AudioRecorderManager()
    
    //form validation
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSaving = false
    
    
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
                    
                    //Audio Recording Option
                    Button(action: {showAudioRecorder = true } ) {
                        HStack {
                            Image(systemName: recordedAudioURL != nil ? "mic.fill" : "mic")
                                .foregroundColor(recordedAudioURL != nil ? .green : .blue)
                            
                            if recordedAudioURL != nil {
                                Text("Audio Recorded")
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                Button(action: {recordedAudioURL = nil}) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    
                                } //button 2 end
                                
                            } else {
                                Text("Add Voice Recording")
                            }//if statement end
                            
                        } //hstack end
                    } //button end
                    
                } //section 2 end
                
                Section {
                    Toggle("Post Anonymously", isOn: $isAnonymous)
                    
                }//section 3 end
                
                Section {
                    Button(action: saveMemory) {
                        HStack {
                            
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Saving...")
                                    .fontWeight(.semibold)
                                
                            } else {
                                Text("Save Memory")
                                    .fontWeight(.semibold)
                            } //if end
                            
                            Spacer()
                            
                        }//hstack end
                        
                    } //button end
                    .disabled(!isFormValid || isSaving)
                    
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
            .sheet(isPresented: $showAudioRecorder) {
                AudioRecorderView(
                    onAudioRecorded: {url in
                        recordedAudioURL = url
                    showAudioRecorder = false},
                    
                    onCancel: {
                        showAudioRecorder = false
                        
                    } //on cancel end
                ) //parentheses end
                
            } //sheet end
            .alert("Cannot Save", isPresented: $showingAlert) {
                
                Button("OK", role: .cancel) {}
                
            } message: {
                Text(alertMessage)
            } //alert end
            
        }//navigation stack end
        
    } //body end
    
    //MARK: WE ADD FUNCTIONS BELOW
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !locationName.trimmingCharacters(in: .whitespaces).isEmpty && (!content.trimmingCharacters(in: .whitespaces).isEmpty || recordedAudioURL != nil)
        
        
    } //var end
    private func saveMemory() {
        //validate input
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a title for your memory"
            showingAlert = true
            return
            
        } //uard statement 1 end
        
        guard !locationName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter a location!"
            showingAlert = true
            return
        }
        
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty || recordedAudioURL != nil else {
            alertMessage = "Please share your story or record an audio"
            showingAlert = true
            return
        }
        
        isSaving = true
        
        //Save audio file if one exists
        task {
            var saveAudioFileName: String? = nil
            if let audioURL = recordedAudioURL {
                let fileName = "\(UUID().uuidString).m4a"
                do {
                    saveAudioFileName = try audioManager.saveAudioFile(from: audioURL, withName: fileName)
                    
                } catch {
                    await MainActor.run {
                        alertMessage = "Failed to save audio recording!"
                        showingAlert = true
                        isSaving = false
                        
                    }//await end
                    return
                }//catch end
                
            }//if let end
            //GEOCODE the location BEFORE creating the memory
            let coordinate = await LocationManager.shared.geocodeLocation(locationName.trimmingCharacters(in: .whitespaces))
            
            //create the memory with coordinates
            let newMemory = Memory(
                title: title.trimmingCharacters(in: .whitespaces),
                content: content.trimmingCharacters(in: .whitespaces),
                locationName: locationName.trimmingCharacters(in: .whitespaces),
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
                isAnonymous: isAnonymous, audioFileName: saveAudioFileName)
            
            await MainActor.run {
                modelContext.insert(newMemory)
                isSaving = false
                dismiss()
                
            }//await end
            
        } //task end
        
    }//func end
} // struct end

#Preview {
    AddMemoryView()
        .modelContainer(for: Memory.self, inMemory: true)
}
