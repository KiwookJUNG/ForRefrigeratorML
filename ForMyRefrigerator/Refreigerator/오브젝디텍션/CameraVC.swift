//
//  CameraVC.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 02/06/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

// Methods for receiving sample buffers from and monitoring the status of a video data output.
// 비디오 데이터의 아웃풋의 상태를 모니터링하고 샘플버퍼를 받기위한 방법을 관리해주는 델리게이트 프로토콜

class CameraVC : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // 버퍼 사이즈는 width 와 height를 0으로 초기화 해준다.
    var bufferSize: CGSize = .zero
    
    // An object that manages image-based content and allows you to perform animations on that content.
    // CALayer는 이미지 기반 콘텐츠를 관리하는 객체이고 그 콘텐츠 위에서 애니메이션 효과를 줄 수 있도록 도와준다.
    // nil값으로 초기화
    var rootLayer: CALayer! = nil
    

    @IBOutlet weak var previewView: UIView!
    
    //An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
    // AVCaptureSession : 인풋 디바이스로 부터 캡쳐 아웃풋까지 데이터의 흐름을 조직화하고 캡쳐 활동을 관리하는 객체
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    
    // A capture output that records video and provides access to video frames for processing.
    // 비디오를 기록하고 비디오 프레임을 위한 프로세싱을 위한 접근을 제공하는 캡쳐 아웃풋
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // DispatchQueue manages the execution of work items. Each work item submitted to a queue is processed on a pool of threads managed by the system.
    // DispatchQueue 는 work itmes들의 실행을 관리하는 객체. 각 work item 은 시스템이 관리하는 스레드들에 의해 큐잉됨.
    // DispatchQueue의 Label을 "VidioDataOutput"으로 설정해준다.
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    
    
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // ObjectDetectionVC에서 구현해줄 인터페이스
    }
    
    // 뷰가 처음 로드될때 호출되는 메소드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
        
        setupAVCapture()
    }
    
    // view가 다시 나타날때 불러주는 메소드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupAVCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:  AVCapture를 위한 설정 메소드
    func setupAVCapture() {
        
        // Capture Device로 부터 받은 Capture Input을 정의하는 변수
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        // 후면 카메라를 이용한 비디오를 AVCaputreDevice에 이용한다.
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        
        do {
            // Capture Input은 비디오 디바이스를 이용해 받는다.
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration() // 해상도를 바꾸기 위해 환경설정 시작. commitConfiguration을 하면 설정됨.
        session.sessionPreset = .vga640x480// Model image size is smaller.
        // 해상도는 vga640x480으로 정의한다. 너무 높은 해상도는 프로세싱 과정에서 배터리 이슈를 일으킬 수 있다.
        
        // Add a video input
        // AVCaptureSession에 비디오를 이용한 캡쳐 인풋을 받을 수 있으면 추가해준다.
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // 캡쳐 세션에 비디오데이터 아웃풋을 추가해준다.
            videoDataOutput.alwaysDiscardsLateVideoFrames = true // 늦게 도착한 비디오 데이터를 버린다.
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            // 비디오데이터 아웃풋이 추가될때마다 호출되는 델리게이트 메소드의 버퍼를 추가해준다.
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
}
