//
//  View.swift
//  Sign Reader
//
//  Created by Vivek Pranavamurthi on 3/1/21.
//
//
//import UIKit
//import AVFoundation
//
//class preview: UIView {
//
//    /*
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
//    */
//    
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
//        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
//            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
//        }
//        return layer
//    }
//    
//    var session: AVCaptureSession? {
//        get {
//            return videoPreviewLayer.session
//        }
//        set {
//            videoPreviewLayer.session = newValue
//        }
//    }
//    
//    override class var layerClass: AnyClass {
//        return AVCaptureVideoPreviewLayer.self
//    }
//
//}
