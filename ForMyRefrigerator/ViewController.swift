//
//  ViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 09/04/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // Methods for receiving sample buffers from and monitoring the status of a video data output.
    // AVCaputreVideoDataOutputSampleBufferDelegate는 샘플 버퍼를 위한 메소드와 비디오 데이터 아웃풋의 상태를 모니터링함.
    var rootLayer: CALayer! = nil
    @IBOutlet weak var object: UILabel!
    @IBOutlet weak var confidence: UILabel!
    @IBOutlet weak var viewForCamera: UIView!
    @IBOutlet weak var rectView: UIView!
    
    @IBOutlet weak var output: UILabel!
    var hasIngredient : [String] = []
    var Str = ""
    
    var ingredient : [String : String] = ["Onion":"양파", "Egg":"달걀", "Green Onion":"대파", "Hairtail":"갈치", "Kimchi":"김치", "Mackerel" :"고등어", "Meat":"소고기", "Milk":"우유", "Pork":"돼지고기", "Red Pepper Paste": "고추장", "Soybean":"된장", "Tofu":"두부"]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.object.layer.masksToBounds = true
        self.object.layer.cornerRadius = 5
        self.confidence.layer.masksToBounds = true
        self.confidence.layer.cornerRadius = 5
        self.output.text = ""
        // Do any additional setup after loading the view, typically from a nib.
      
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.14, green:0.35, blue:0.91, alpha:1.0)
        
        self.rectView.layer.borderColor = UIColor(red:0.67, green:0.71, blue:0.80, alpha:1.0).cgColor
        self.rectView.layer.borderWidth = 2
        self.rectView.layer.masksToBounds = true
        self.rectView.layer.cornerRadius = 5
        
        
        
        // 카메라 시작
        // 카메라 동영상을 위한 AVCaptureSession 인스턴스 생성
        // An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
        let captureSession = AVCaptureSession()
        // 사진 수준의 퀄리티를 전송한다.
        captureSession.sessionPreset = .photo
        
        // 인풋을 주는 디바이스를 디폴트로하고 ( 폰의 카메라, 동영상으로 설정 )
        guard let captureDevice =
            AVCaptureDevice.default(for: .video) else { return }
        
        // 위에서 정한 디바이스가 보내주는 카메라의 인풋
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // 인스턴스는 인풋을 더해준다.
        captureSession.addInput(input)
        
        // AVCaptureSession을 시작한다.
        captureSession.startRunning()
        
        // 캡쳐하고 있는 비디오 화면을 보여주는 Vedio레이어
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = viewForCamera.layer
        previewLayer.frame = rootLayer.bounds
        
        previewLayer.addSublayer(rectView.layer)
        rectView.frame.origin.x = 40
        rectView.frame.origin.y = 40
        rootLayer.addSublayer(previewLayer)
        

        // A capture output that records video and provides access to video frames for processing.
        // 비디오가 제공하고 있는 데이터 아웃풋
        let dataOutput = AVCaptureVideoDataOutput()
        // 비디오가 제공하는 아웃풋을 모니터링하기 위해 샘픒 버퍼를 할당해준다.
        // 데이터 아웃풋을 모니터링 되기 위하여 DispatchQueue큐에 저장된다.
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        

    }


    // Notifies the delegate that a new video frame was written.
    // 델리게이트에게 새로운 비디오 프레임이 찍고 있는 것을 알려주고 그때 실시하는 메소드
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Returns a sample buffer's CVImageBuffer of media data.
        // 매개변수로 받은 샘플버퍼를 리턴해준다.
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 사용할 MLModel을 결정해준다.
        guard let model = try? VNCoreMLModel(for: Advanced().model) else { return }
        
        
        //An image analysis request that uses a Core ML model to process images.
        // ML model을 사용한 이미지의 분석 요청
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // 에러 체크
            // print(finishedReq.results)
            
            // 분류된 이미지의 결과를 출력해주기 위해 results에 분석된 이미지 결과 할당
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
        
            
            DispatchQueue.main.async { // Correct
                
//                if ( self.hasIngredient.count >= 1){
//
//                }
                
                if (firstObservation.confidence > 0.61)
                {
                    if( !self.hasIngredient.contains(String(firstObservation.identifier)))
                    {
                        self.hasIngredient.append(firstObservation.identifier)
                        self.Str = self.Str + "\(self.ingredient[firstObservation.identifier]!) "
                    }
                }
                
                self.object.text = "물체 : \(self.ingredient[firstObservation.identifier]!)"
                self.confidence.text = "정확도 : \(round(firstObservation.confidence*100)/100)"
                //round(avgTemp*100)/100
                
                
                self.output.text = self.Str
                
                
            }
            
            
        }
        // 이미지 분석 요청을 Array로 받아 관리한다.
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientSegue" {
            
            let IngredientInfo = segue.destination as? DetailViewController
            IngredientInfo?.hasIngredient = self.hasIngredient
        }
    }

}

