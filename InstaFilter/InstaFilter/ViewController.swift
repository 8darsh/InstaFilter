//
//  ViewController.swift
//  InstaFilter
//
//  Created by Adarsh Singh on 10/09/23.
//

import UIKit
import CoreImage
class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var intensity: UISlider!
    
    @IBOutlet var radius: UISlider!
    
    var currentImg: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "InstaFilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPics))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    
    @objc
    func addPics(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        dismiss(animated: true)
        currentImg = image
        
        let beginImage = CIImage(image: currentImg)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @IBAction func changeFilterBtn(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController{
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction){
        guard currentImg != nil else {return}
        guard let actionTitle = action.title else {return}
        
        currentFilter = CIFilter(name: actionTitle)
        title = actionTitle
        let beginImage = CIImage(image: currentImg)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        if (currentFilter.name == "CIBumpDistortion" || currentFilter.name == "CIGaussianBlur" || currentFilter.name == "CITwirlDistortion"){
            
            applyProcessingRadius()
        }else{
            
            applyProcessing()
        }
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        if (imageView.image == nil){
            let ac = UIAlertController(title: "Add Image", message: "No Image Found", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac,animated: true)
        }else{
            
            guard let image = imageView.image else { return }
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func intensityBtn(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func radiusSlider(_ sender: UISlider) {
        applyProcessingRadius()
    }
    
    
    func applyProcessingRadius(){
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(radius.value * 10, forKey: kCIInputScaleKey)
            
        }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImg.size.width / 2, y: currentImg.size.height / 2), forKey: kCIInputCenterKey)
        }

        guard let outPutImage = currentFilter.outputImage else {return}
       
        
        if let cgImage = context.createCGImage(outPutImage, from: outPutImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
        
    }
    
    func applyProcessing(){
        
        let inputKeys = currentFilter.inputKeys
       
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            
        }
//        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)

        }
//        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImg.size.width / 2, y: currentImg.size.height / 2), forKey: kCIInputCenterKey)
//        }

        guard let outPutImage = currentFilter.outputImage else {return}
       
        
        if let cgImage = context.createCGImage(outPutImage, from: outPutImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?,contextInfo: UnsafeRawPointer){
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    


}

