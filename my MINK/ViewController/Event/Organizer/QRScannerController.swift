//
//  QRScannerController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//


import UIKit
import AVFoundation
import Lottie
import Firebase
import CoreLocation


class QRScannerController: UIViewController, CLLocationManagerDelegate {
    
    
    
 
    @IBOutlet weak var scan: LottieAnimationView!
    @IBOutlet weak var scannerView: UIView!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    
    
    
    @objc func update() {
        captureSession.startRunning()
        scan.contentMode = .scaleAspectFit
        
        // 2. Set animation loop mode
        
        scan.loopMode = .loop
        
        // 3. Adjust animation speed
        
        scan.animationSpeed = 0.5
        
        // 4. Play animation
        scan.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = scannerView.layer.bounds
        videoPreviewLayer?.cornerRadius = 16
        scannerView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        update()
        
        // Initialize QR Code Frame to highlight the QR code
        
        
        
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.scannerView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scannerView.frame = CGRect.zero
            
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            scannerView.frame = barCodeObject!.bounds

            if let ticketId = metadataObj.stringValue {
                
                if metadataObj.stringValue != nil {
                    captureSession.stopRunning()
                }
                
                self.ProgressHUDShow(text: "Scanning...")
                Firestore.firestore().collection(Collections.TICKETS.rawValue).document(ticketId).getDocument { snashot, error in
                    if error == nil {
                        if let snapshot = snashot, snapshot.exists{
                            if let ticket = try? snashot?.data(as: TicketModel.self) {
                                if let isCheckedIn = ticket.isCheckedIn, isCheckedIn {
                                    self.ProgressHUDHide()
                                    let time = self.convertDateAndTimeFormater(ticket.checkedInTime ?? Date())
                                    let messageString = "This ticket has already checked in at"
                                    let alert = UIAlertController(title: "Duplicate Entry", message: "\(messageString)\n\(time)", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
                                        self.dismiss(animated: true, completion: nil)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                   
                                   
                                }
                                else {
                                    Firestore.firestore().collection(Collections.TICKETS.rawValue).document(ticketId).setData(["isCheckedIn" : true, "checkedInTime" : FieldValue.serverTimestamp()],merge: true) { error in
                                        self.ProgressHUDHide()
                                        if error == nil {
                                            self.showSnack(messages: "Checked In")
                                            DispatchQueue.main.async {
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                        else {
                                            self.showSnack(messages: error!.localizedDescription)
                                            DispatchQueue.main.async {
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }
                            }
                           
                        }
                        else {
                            self.ProgressHUDHide()
                            self.showSnack(messages: "No ticket available for this qr code")
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        self.ProgressHUDHide()
                        self.showError(error!.localizedDescription)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
            
                       
                    }
                }
                
                
                
            }
                
            
        
    }
        
        
}
    
    

   
    
    
    
    
    
}



