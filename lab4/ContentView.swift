//
//  ContentView.swift
//  lab4
//
//  Created by Иван Ерофеевский on 04.12.2024.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    @State private var currentLine = [CGPoint]()
    @State private var lines = [[CGPoint]]()
    
    func saveImageToPhotoLibrary(image: UIImage?) {
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @State private var showImagePicker = false

    var body: some View {
        ZStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                currentLine.append(value.location)
                            }
                            .onEnded { _ in
                                lines.append(currentLine)
                                currentLine = []
                            })
                
                
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line)
                        context.stroke(path, with: .color(.black), lineWidth: 2)
                    }
                    if !currentLine.isEmpty {
                        var path = Path()
                        path.addLines(currentLine)
                        context.stroke(path, with: .color(.blue), lineWidth: 2)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentLine.append(value.location)
                        }
                        .onEnded { _ in
                            lines.append(currentLine)
                            currentLine = []
                        })
                
            }
        }
        PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Text("Выбрать фото")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            showImagePicker = true
                            selectedImage = uiImage
                        }
                    }
                }
        Button(action: {
            UIImageWriteToSavedPhotosAlbum(selectedImage!, self, nil, nil)
        }) {
            Text("Сохранить фото")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 20)
    }
}



