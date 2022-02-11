//
//  ViewController.swift
//  Sign Reader
//
//  Created by Vivek Pranavamurthi on 3/1/21.
//

import UIKit
import AVFoundation
import Vision



class ViewController: UIViewController {
    
    //  Data output
    public let videoDataOutputQueue = DispatchQueue(
      label: "CameraFeedOutput",
      qos: .userInteractive
    )
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!


    @IBOutlet var videoOutput: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var flipCamButton: UIButton!
    
    
    var previewLayer : AVCaptureVideoPreviewLayer!

    var captureSession : AVCaptureSession!
    var imageView: UIImageView = UIImageView()
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    // Display points
    public var overlayLayer = CAShapeLayer()
    public var pointsPath = UIBezierPath()
    private var gestureProcessor = GestureProcessor()
    
    let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "sbPopUpID") as! ViewController_popUp
    
    // hand fingers
    //var activeHand: Fingers;

    // HandPose
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
      // 1
      let request = VNDetectHumanHandPoseRequest()
      
      // 2
      request.maximumHandCount = 2
      return request
    }()
    
    
    // Define which camera to use
    let cameras = ["back", "front"]
    var currentCam = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
        


        checkPermissions()
        setupAndStartCaptureSession()
        
        // Setup Character Display
        view.addSubview(imageView)
        
    }

    
    public func closePanel() {
        popUpVC.removeFromParent()
        popUpVC.view.removeFromSuperview()
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        switchCameraInput()
        closePanel()
    }
    
    // Point Processing
    func processPoints(fingers: PossibleFingers) {
        print("thumbTip", fingers.thumb.TIP)

        // Check that we have both points.
        guard let thumbTip = fingers.thumb.TIP,
              let thumbIp = fingers.thumb.IP,
              let thumbMp = fingers.thumb.MP,
              let thumbCmc = fingers.thumb.CMC,
              let indexTip = fingers.index.TIP,
              let indexDip = fingers.index.DIP,
              let indexPip = fingers.index.PIP,
              let indexMcp = fingers.index.MCP,
              let middleTip = fingers.middle.TIP,
              let middleDip = fingers.middle.DIP,
              let middlePip = fingers.middle.PIP,
              let middleMcp = fingers.middle.MCP,
              let ringTip = fingers.ring.TIP,
              let ringDip = fingers.ring.DIP,
              let ringPip = fingers.ring.PIP,
              let ringMcp = fingers.ring.MCP,
              let littleTip = fingers.little.TIP,
              let littleDip = fingers.little.DIP,
              let littlePip = fingers.little.PIP,
              let littleMcp = fingers.little.MCP,
              let wrist = fingers.wrist else {
            // If there were no observations for more than 2 seconds reset gesture processor.
//            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
//                gestureProcessor.reset()
//            }
            
            
            showPoints(letter: "", [])
            return
        }
        
        // Convert
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let thumbTipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbTip)
        let thumbIpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbIp)
        let thumbMpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbMp)
        let thumbCmcConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbCmc)
        
        let indexTipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexTip)
        let indexDipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexDip)
        let indexPipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPip)
        let indexMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexMcp)
        
        let middleTipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleTip)
        let middleDipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleDip)
        let middlePipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middlePip)
        let middleMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middleMcp)
        
        let ringTipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringTip)
        let ringDipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringDip)
        let ringPipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPip)
        let ringMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringMcp)
        
        let littleTipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littleTip)
        let littleDipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littleDip)
        let littlePipConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littlePip)
        let littleMcpConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littleMcp)
        
        let wristConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: wrist)
  
        // Create a true hand object
        // Process new points
        let fingers = Fingers(thumb: Thumb(TIP: thumbTipConverted, IP: thumbIpConverted, MP: thumbMpConverted, CMC: thumbCmcConverted),
                              index: Finger(TIP: indexTipConverted, DIP: indexDipConverted, PIP: indexPipConverted, MCP: indexMcpConverted),
                              middle: Finger(TIP: middleTipConverted, DIP: middleDipConverted, PIP: middlePipConverted, MCP: middleMcpConverted),
                              ring: Finger(TIP: ringTipConverted, DIP: ringDipConverted, PIP: ringPipConverted, MCP: ringMcpConverted),
                              little: Finger(TIP: littleTipConverted, DIP: littleDipConverted, PIP: littlePipConverted, MCP: littleMcpConverted),
                              wrist: wristConverted)

        //  showPoints([fingers.thumb.TIP, ])
        let currentLetter = gestureProcessor.processFingerPoints(fingers)
        showPoints(letter: currentLetter, [fingers.thumb.TIP, fingers.thumb.IP, fingers.thumb.MP, fingers.thumb.CMC, fingers.index.TIP, fingers.index.PIP, fingers.index.MCP, fingers.middle.TIP, fingers.middle.MCP, fingers.middle.PIP, fingers.ring.TIP, fingers.ring.MCP, fingers.ring.PIP, fingers.little.TIP, fingers.little.MCP])
    }

    
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
          case .authorized:
            return
          case .denied:
            abort()
          case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
            { (authorized) in
              if(!authorized){
                abort()
              }
            })
          case .restricted:
            abort()
          @unknown default:
            fatalError()
        }
    }
    
    func setupPreviewLayer()
    {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(previewLayer, below: flipCamButton.layer)
        previewLayer.addSublayer(overlayLayer)
        previewLayer.frame = self.view.layer.frame
    }
    
    func showPoints(letter: String, _ points: [CGPoint])
    {
        pointsPath.removeAllPoints()
        
        var l = CGFloat(1000)
        var t = CGFloat(0)
        var r = CGFloat(0)
        var b = CGFloat(1000)
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            if point.x < l {
                l = point.x
            }
            if point.y < b {
                b = point.y
            }
            if point.x > r {
                r = point.x
            }
            if point.y > t {
                t = point.y
            }
            
        }
        displayImage(letter: letter, left: l, bottom: b, right: r, top: t)

//        overlayLayer.fillColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
//        overlayLayer.strokeColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
//        overlayLayer.lineWidth = 5.0
//        overlayLayer.lineCap = .round
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        overlayLayer.path = pointsPath.cgPath
//        CATransaction.commit()
        

    }
    func displayImage(letter: String, left : CGFloat, bottom : CGFloat, right :CGFloat, top :CGFloat) {
        let imageName: String
        let folder = "Alphabet/"
        let filename = "-Alphabet-PNG.png"
        
        if(letter != ""){
            imageName = folder+letter+".png"
        }
        else {
            imageName = "none.png"
        }
        

        let image = UIImage(named: imageName)
        imageView.image = image
        imageView.frame = CGRect(x: left, y: bottom, width: (right-left), height: (top-bottom))
    }
}



extension
ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var thumbTip: CGPoint?
        var thumbIp: CGPoint?
        var thumbMp: CGPoint?
        var thumbCmc: CGPoint?
        
        var indexTip: CGPoint?
        var indexDip: CGPoint?
        var indexPip: CGPoint?
        var indexMcp: CGPoint?
        
        var middleTip: CGPoint?
        var middleDip: CGPoint?
        var middlePip: CGPoint?
        var middleMcp: CGPoint?
        
        var ringTip: CGPoint?
        var ringDip: CGPoint?
        var ringPip: CGPoint?
        var ringMcp: CGPoint?
        
        var littleTip: CGPoint?
        var littleDip: CGPoint?
        var littlePip: CGPoint?
        var littleMcp: CGPoint?
        
        var wrist: CGPoint?
        var fingerTips: [CGPoint] = []
        defer {
          DispatchQueue.main.sync {
            self.processPoints(fingers: PossibleFingers(thumb: PossibleThumb(TIP: thumbTip, IP: thumbIp, MP: thumbMp, CMC: thumbCmc),
                                                        index: PossibleFinger(TIP: indexTip, DIP: indexDip, PIP: indexPip, MCP: indexMcp),
                                                        middle: PossibleFinger(TIP: middleTip, DIP: middleDip, PIP: middlePip, MCP: middleMcp),
                                                        ring: PossibleFinger(TIP: ringTip, DIP: ringDip, PIP: ringPip, MCP: ringMcp),
                                                        little: PossibleFinger(TIP: littleTip, DIP: littleDip, PIP: littlePip, MCP: littleMcp),
                                                        wrist: wrist))
          }
        }
        var recognizedPoints: [VNRecognizedPoint] = []
        let handler = try? VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
    
        do {
            try handler?.perform([handPoseRequest])

            guard
                let results = handPoseRequest.results?.first
            else {
                return
            }

            let thumbPoints = try results.recognizedPoints(forGroupKey: .handLandmarkRegionKeyThumb)
            let indexFingerPoints = try results.recognizedPoints(forGroupKey: .handLandmarkRegionKeyIndexFinger)
            let middleFingerPoints = try results.recognizedPoints(forGroupKey: .handLandmarkRegionKeyMiddleFinger)
            let ringFingerPoints = try results.recognizedPoints(forGroupKey: .handLandmarkRegionKeyRingFinger)
            let littleFingerPoints = try results.recognizedPoints(forGroupKey: .handLandmarkRegionKeyLittleFinger)
            let wristPoints = try results.recognizedPoints(forGroupKey: .all)

            print("Thumbes", thumbPoints)

            guard let thumbTipPoint = thumbPoints[.handLandmarkKeyThumbTIP],
                  let thumbIpPoint = thumbPoints[.handLandmarkKeyThumbIP],
                  let thumbMpPoint = thumbPoints[.handLandmarkKeyThumbMP],
                  let thumbCMCPoint = thumbPoints[.handLandmarkKeyThumbCMC] else {
                return
            }
            guard let indexTipPoint = indexFingerPoints[.handLandmarkKeyIndexTIP],
                  let indexDipPoint = indexFingerPoints[.handLandmarkKeyIndexDIP],
                  let indexPipPoint = indexFingerPoints[.handLandmarkKeyIndexPIP],
                  let indexMcpPoint = indexFingerPoints[.handLandmarkKeyIndexMCP] else {
                return
            }

            guard let middleTipPoint = middleFingerPoints[.handLandmarkKeyMiddleTIP],
                  let middleDipPoint = middleFingerPoints[.handLandmarkKeyMiddleDIP],
                  let middlePipPoint = middleFingerPoints[.handLandmarkKeyMiddlePIP],
                  let middleMcpPoint = middleFingerPoints[.handLandmarkKeyMiddleMCP] else {
                return
            }

            guard let ringTipPoint = ringFingerPoints[.handLandmarkKeyRingTIP],
                  let ringDipPoint = ringFingerPoints[.handLandmarkKeyRingDIP],
                  let ringPipPoint = ringFingerPoints[.handLandmarkKeyRingPIP],
                  let ringMcpPoint = ringFingerPoints[.handLandmarkKeyRingMCP] else {
                return
            }

            guard let littleTipPoint = littleFingerPoints[.handLandmarkKeyLittleTIP],
                  let littleDipPoint = littleFingerPoints[.handLandmarkKeyLittleDIP],
                  let littlePipPoint = littleFingerPoints[.handLandmarkKeyLittlePIP],
                  let littleMcpPoint = littleFingerPoints[.handLandmarkKeyLittleMCP] else {
                return
            }

            guard let wristPoint = wristPoints[.handLandmarkKeyWrist] else {
                return
            }

            let minimumConfidence: Float = 0.3
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > minimumConfidence,
                  thumbIpPoint.confidence > minimumConfidence,
                  thumbMpPoint.confidence > minimumConfidence,
                  thumbCMCPoint.confidence > minimumConfidence else {
                return
            }

            guard indexTipPoint.confidence > minimumConfidence,
                  indexDipPoint.confidence > minimumConfidence,
                  indexPipPoint.confidence > minimumConfidence,
                  indexMcpPoint.confidence > minimumConfidence else {
                return
            }

            guard middleTipPoint.confidence > minimumConfidence,
                  middleDipPoint.confidence > minimumConfidence,
                  middlePipPoint.confidence > minimumConfidence,
                  middleMcpPoint.confidence > minimumConfidence else {
                return
            }

            guard ringTipPoint.confidence > minimumConfidence,
                  ringDipPoint.confidence > minimumConfidence,
                  ringPipPoint.confidence > minimumConfidence,
                  ringMcpPoint.confidence > minimumConfidence else {
                return
            }

            guard littleTipPoint.confidence > minimumConfidence,
                  littleDipPoint.confidence > minimumConfidence,
                  littlePipPoint.confidence > minimumConfidence,
                  littleMcpPoint.confidence > minimumConfidence else {
                return
            }

            guard wristPoint.confidence > minimumConfidence else {
                return
            }

            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            thumbIp = CGPoint(x: thumbIpPoint.location.x, y: 1 - thumbIpPoint.location.y)
            thumbMp = CGPoint(x: thumbMpPoint.location.x, y: 1 - thumbMpPoint.location.y)
            thumbCmc = CGPoint(x: thumbCMCPoint.location.x, y: 1 - thumbCMCPoint.location.y)

            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            indexDip = CGPoint(x: indexDipPoint.location.x, y: 1 - indexDipPoint.location.y)
            indexPip = CGPoint(x: indexPipPoint.location.x, y: 1 - indexPipPoint.location.y)
            indexMcp = CGPoint(x: indexMcpPoint.location.x, y: 1 - indexMcpPoint.location.y)

            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            middleDip = CGPoint(x: middleDipPoint.location.x, y: 1 - middleDipPoint.location.y)
            middlePip = CGPoint(x: middlePipPoint.location.x, y: 1 - middlePipPoint.location.y)
            middleMcp = CGPoint(x: middleMcpPoint.location.x, y: 1 - middleMcpPoint.location.y)

            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            ringDip = CGPoint(x: ringDipPoint.location.x, y: 1 - ringDipPoint.location.y)
            ringPip = CGPoint(x: ringPipPoint.location.x, y: 1 - ringPipPoint.location.y)
            ringMcp = CGPoint(x: ringMcpPoint.location.x, y: 1 - ringMcpPoint.location.y)

            littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            littleDip = CGPoint(x: littleDipPoint.location.x, y: 1 - littleDipPoint.location.y)
            littlePip = CGPoint(x: littlePipPoint.location.x, y: 1 - littlePipPoint.location.y)
            littleMcp = CGPoint(x: littleMcpPoint.location.x, y: 1 - littleMcpPoint.location.y)

            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
        } catch {
            captureSession?.stopRunning()
        }
    }
    
}

