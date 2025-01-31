//
//  ContentView.swift
//  lab4
//
//  Created by Иван Ерофеевский on 04.12.2024.
//

import SwiftUI


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct Line {
    var points: [CGPoint]
    var color: Color
    var strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
}
struct ContentView: View {
    
    @State private var image: UIImage? = UIImage()

    @State private var lines: [Line] = []
    @State private var selectedColor = Color.black
    
    var canvas: some View {
            Canvas {ctx, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    ctx.stroke(path, with: .color(line.color), style: line.strokeStyle)
                }
            }
            .background(
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFit()
            )
            .frame(width: 400, height: 400)
    }
    
    var body: some View {
        VStack {
            HStack{
                choosePhotoButton()
                savePhotoButton()
            }
            HStack {
                ForEach([Color.green, .orange, .blue, .red, .black, .purple], id: \.self) { color in
                    colorButton(color: color)
                }
                clearButton()
            }
            canvas.gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let position = value.location
                        
                        if value.translation == .zero {
                            lines.append(Line(points: [position], color: selectedColor))
                        } else {
                            guard let lastIdx = lines.indices.last else {
                                return
                            }
                            lines[lastIdx].points.append(position)
                        }
                    })
            )
        }
    }
    
    @ViewBuilder
    func colorButton(color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            Image(systemName: "circle.fill")
                .font(.largeTitle)
                .foregroundColor(color)
                .mask {
                    Image(systemName: "pencil.tip")
                        .font(.largeTitle)
                }
        }
    }
    
    @ViewBuilder
    func clearButton() -> some View {
        Button {
            lines = []
        } label: {
            Image(systemName: "pencil.tip.crop.circle.badge.minus")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    func choosePhotoButton() -> some View {
        Button {
            selectImage()
        } label: {
            Image(systemName: "photo")
                .font(.largeTitle)
        }
            
    }
    
    @ViewBuilder
    func savePhotoButton() -> some View {
        Button {
            saveToPhotoLibrary()
        } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.largeTitle)
        }
            
    }
    
    func selectImage() {
        let imagePicker = ImagePickerView(image: $image)
        let controller = UIHostingController(rootView: imagePicker)
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
    }
    
    func saveToPhotoLibrary() {
        UIImageWriteToSavedPhotosAlbum(canvas.scaledToFit().snapshot(), self, nil, nil)
    }
    
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
