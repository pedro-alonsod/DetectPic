//
//  ViewController.swift
//  DetectPic
//
//  Created by Pedro Alonso on 6/28/18.
//  Copyright © 2018 Pedro Alonso. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var mobileNetModel = MobileNet()
    
    var rowsForTable: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.imagePicker.delegate = self
        
//        tableView.delegate = self
        self.tableView.dataSource = self
        if let image = imageView.image {
            processPicture(image: image)
        }
    }
    
    func processPicture(image: UIImage) {
        if let model = try? VNCoreMLModel(for: mobileNetModel.model) {
            let request = VNCoreMLRequest(model: model) { (reques, error) in
                if error == nil {
                    if let results = reques.results as? [VNClassificationObservation] {
                        print(results)
                        
                        for i in 0..<10 {
                            print("\(results[i].identifier) with: \(results[i].confidence * 100) prob. ")
                            self.rowsForTable.append("\(results[i].identifier) with: \(results[i].confidence * 100) prob. ")
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    
                }
            }
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsForTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = rowsForTable[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }

    @IBAction func takePictureTapped(_ sender: UIBarButtonItem) {
    
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func folderTapped(_ sender: UIBarButtonItem) {
    
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Fin")
        self.rowsForTable = []
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processPicture(image: image)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

