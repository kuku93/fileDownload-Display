//
//  ViewController.swift
//  downloadCSV
//

import UIKit
import QuickLook

class ViewController: UIViewController {

    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var btnDownload: UIButton!
    
    var destinationFileUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showStack.isHidden = true
        btnDownload.isHidden = false
    }

    @IBAction func btnDownloadTapped(_ sender: Any) {
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        destinationFileUrl = documentsUrl.appendingPathComponent("FILENAME.EXTENSION")
        
        //Create URL to the source file you want to download
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let fileURL = URL(string: "YOUR-FILE-URL")
        let request = URLRequest(url:fileURL!)
        
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            showAlert(with: "File already exist on the path", title: "File exist")
            
            DispatchQueue.main.async {
                self.showStack.isHidden = false
                self.btnDownload.isHidden = true
            }
        } else {
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                        
                        DispatchQueue.main.async {
                            self.showStack.isHidden = false
                            self.btnDownload.isHidden = true
                        }                        
                    }
                    
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: self.destinationFileUrl)
                    } catch (let writeError) {
                        let msg = "Error creating a file \(self.destinationFileUrl.lastPathComponent) : \(writeError)"
                        self.showAlert(with: msg, title: "Error")
                    }
                    
                } else {
                    let msg = "Error took place while downloading a file. Error description: \(error?.localizedDescription as Any)"
                    self.showAlert(with: msg, title: "Error")
                }
            }
            task.resume()
        }
    }
    
    @IBAction func btnShowFileTapped(_ sender: Any) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
}

// MARK: - Alert
extension ViewController {
    func showAlert(with message: String, title: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = destinationFileUrl else {
            showAlert(with: "Could not load \(destinationFileUrl.lastPathComponent)", title: "Error")
            fatalError("Could not load")
        }
        
        return url as QLPreviewItem
    }
}
