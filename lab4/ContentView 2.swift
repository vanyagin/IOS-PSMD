//
//  ContentView.swift
//  lab4
//
//  Created by Иван Ерофеевский on 04.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var drawingPaths: [IdentifiablePath] = []
    @State private var currentDrawingPath: Path?
    @State private var currentColor: Color = .blue
    @State private var isErasing = false
    
    
    @State private var currentLine = [CGPoint]()
    @State private var lines = [[CGPoint]]()
    
    

    var body: some View {
        
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .background(
                            Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            )
                        .overlay(
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
                        
                        )
                } else {
                    Text("Choose an image to start drawing")
                }
                
                HStack(spacing: 20) {
                    
                    Button(action: {
                        isErasing.toggle()
                    }) {
                        Label(isErasing ? "Stop Eraser" : "Erase", systemImage: "eraser")
                    }
                    
                    Button(action: {
                        clearAllLines()
                    }) {
                        Label("Clear All", systemImage: "trash")
                    }
                    
                    Button(action: {
                        saveToPhotoLibrary()
                    }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
                .padding(.top)
                
                
                
            }
            .navigationBarTitle("Drawing App")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        selectImage()
                    }) {
                        Label("Select Image", systemImage: "photo")
                    }
                }
            }
        }
    }
    
    func selectImage() {
        let imagePicker = ImagePickerView(image: $image)
        let controller = UIHostingController(rootView: imagePicker)
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
    }
    
    func addLine(to point: CGPoint) {
        guard !isErasing else { return }
        
        withAnimation {
            if currentDrawingPath == nil {
                currentDrawingPath = Path()
            }
            currentDrawingPath!.move(to: CGPoint(x: 0, y: 0))
            currentDrawingPath!.addLine(to: point)
        }
    }
    
    func endLine() {
        if let currentDrawingPath = currentDrawingPath {
            drawingPaths.append(IdentifiablePath(path: currentDrawingPath))
        }
        currentDrawingPath = nil
    }
    
    func clearAllLines() {
        drawingPaths = []
    }
    
    func saveToPhotoLibrary() {
        guard let image = image else { return }
        
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let finalImage = renderer.image { ctx in
            image.draw(at: .zero)
            for identifiablePath in drawingPaths {
                identifiablePath.path.stroke(currentColor, lineWidth: 10)
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
    }
}

struct IdentifiablePath: Identifiable {
    let id = UUID()
    let path: Path
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
