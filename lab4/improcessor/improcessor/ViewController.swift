//
//  ViewController.swift
//  improcessor
//
//  Created by Илья Лошкарёв on 09.03.17.
//  Copyright © 2017 Илья Лошкарёв. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    
    var taped = false
    var lastPoint = CGPoint.zero
    var strokeWidth: CGFloat = 12.0
    var strokeColor = UIColor.blue
    
    var linePath: UIBezierPath?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        taped = true
        if let touch = touches.first {
            lastPoint = touch.location(in: view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        taped = false
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLine(from: lastPoint, to: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if taped {
            drawLine(from: lastPoint, to: lastPoint)
        }
    }
    
    @objc func longPress() {
        let activity = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        present(activity, animated:true, completion:nil)
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint:CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        imageView.image?.draw(in: CGRect(origin: CGPoint.zero, size: view.frame.size))
        
        let linePath = UIBezierPath()
        
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        
        strokeColor.setStroke()
        linePath.lineWidth = strokeWidth
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        linePath.stroke()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var currentFilterName = "CIColorInvert"
    let context = CIContext()
    
    var miniature: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view = UIImageView(frame: view.bounds)
        //view.backgroundColor = UIColor.white
        //view.isUserInteractionEnabled = true
        
        
        saveButton.isEnabled = false
        scrollView.backgroundColor = .white
        cameraButtonTouched(self)
        
        imageView.isUserInteractionEnabled = true
        imageView.frame = imageView.bounds
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        imageView.addGestureRecognizer(press)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError: contextInfo:)), nil)

    }
    
    @IBAction func cameraButtonTouched(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
        
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func filterButtonTouched(_ sender: Any) {
        //process(image: imageView.image!)
    }
    
    // MARK: ImageDidFinishSavingWithError
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            print ("saveing error")
            return
        }
        
        let alert = UIAlertController(title: "Saved", message: "Image saved to default photo album", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: ImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        dismiss(animated: true, completion: nil)
        update(with: info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        miniature = createMiniature(from: imageView.image!)
        filterButton.image = filter(inputImage: miniature)
    }
    
    
    // MARK: ScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: Image Processing
    
    func process(image: UIImage) {
        self.imageView.alpha = 0.1
        self.activityIndicator.startAnimating()
        self.scrollView.isUserInteractionEnabled = false
        
        DispatchQueue.global().async {
            [weak self] in
            guard let resultImage = self?.filter(inputImage: image)
            else {
                return
            }
            DispatchQueue.main.sync {
                [weak self] in
                self?.update(with: resultImage)
                
                self?.activityIndicator.stopAnimating()
                self?.scrollView.isUserInteractionEnabled = true
                self?.saveButton.isEnabled = true
                UIView.animate(withDuration: 0.5) {
                    self?.imageView.alpha = 1
                }
            }
        }

    }
    
    func filter(inputImage image: UIImage) -> UIImage? {
        guard let filter = CIFilter(name: currentFilterName)
        else {
            print("Wrong filter", currentFilterName)
            return nil
        }
        return filter.apply(to: image)?.withRenderingMode(.alwaysOriginal)
    }
    
    func update(with image: UIImage) {
        scrollView.setZoomScale(scrollView.maximumZoomScale, animated: false)
        //let url = URL(fileURLWithPath: "/usr/local/lib")
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        imageView.image = image
        
        miniature = createMiniature(from: image)
        filterButton.image = filter(inputImage: miniature)
        
        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = min(scrollView.frame.width  / image.size.width,
                                          scrollView.frame.height / image.size.height)
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    func createMiniature(from image: UIImage) -> UIImage {
        let height: CGFloat = 30
        let width = image.size.width * height / image.size.height
        
        UIGraphicsBeginImageContext( CGSize(width: width, height: height))
        imageView.image!.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

