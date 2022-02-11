//
//  ViewController-extension.swift
//  Sign Reader
//
//  Created by Vivek Pranavamurthi on 3/7/21.
//

import UIKit
import AVFoundation


extension ViewController {


    func switchCameraInput() {
        // Determine index
        if currentCam < cameras.count - 1 {
            currentCam += 1
        }
        else {
            currentCam = 0
        }
        // Take camera
        let camera = cameras[currentCam]
        
        // Switch Camera
        switch camera {
            case cameras[0]:
                captureSession.removeInput(frontInput)
                captureSession.addInput(backInput)
            case cameras[1]:
                captureSession.removeInput(backInput)
                captureSession.addInput(frontInput)
            default:
                print("error")
        }
    }
    

    
    func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            // initialize seesion
            self.captureSession = AVCaptureSession()
            // start configuration
            self.captureSession.beginConfiguration()
            
            // do some configureation?
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            // setup Inputs
            self.setupInputs()
            self.setupOutputs()
            
            DispatchQueue.main.async {
                // Setup preview layer
                self.setupPreviewLayer()
            }
            
            //commit configruation
            self.captureSession.commitConfiguration()
            
            // start running
            self.captureSession.startRunning()
        }
    }
    // Outputs
    func setupOutputs()
    {
        // 5
        let dataOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(dataOutput) {
          captureSession.addOutput(dataOutput)
          dataOutput.alwaysDiscardsLateVideoFrames = true
          dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
          fatalError("no output")
        }
    }

    func setupInputs()
    {
        // get back camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else  {
            fatalError("no Back Camera")
        }
        
        // get front camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else  {
            fatalError("no Front Camera")
        }
        
        // Create an input object from our device
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("Could not create input from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(bInput) {
            fatalError("could not add back camera input to capture session")
        }
    
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("Could not add front camera as input device")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        // connect back camera input to session
        captureSession.addInput(backInput)
        
    }


}
