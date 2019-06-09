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
    var rootLayer: CALayer! = nil // 카메라 레이어를 표시해줄 Root Rayer
    
    @IBOutlet weak var object: UILabel! // 물체의 라벨을 표시해주는 레이블 변수
    @IBOutlet weak var confidence: UILabel! // 물체의 정확도를 표시해주는 레이블 변수
    @IBOutlet weak var viewForCamera: UIView! // 카메라를 내보내주는 뷰
    @IBOutlet weak var rectView: UIView! // 사각형 프레임을 표시해주는 뷰
    
    @IBOutlet weak var output: UILabel! // 객체 인식을 통해 일정 정확도가 넘어가면 인식한 재료를 표시해주는 변수
    var hasIngredient : [String] = [] // DetailViewController로 재료를 전달해줄 배열 변수
    var Str = ""
    
    var IVO : IngredientVO!
    
    var ingredient : [String : String] = ["Bean Sprouts": "콩나물", "Broccoli":"브로콜리", "Cabbage":"양배추", "Carrot":"당근", "Chicken":"닭", "Chili":"고추", "Corn":"옥수수", "Crab":"꽃게", "Cucumber":"오이", "Daikon":"무", "Egg":"달걀", "Eggplant":"가지", "Garlic":"마늘", "Ginger":"생강", "Ginseng":"인삼", "Green Onion":"대파", "Jujube":"대추", "Kimchi":"김치", "Lettuce":"상추", "Mackerel":"고등어", "Manila Calm":"바지락", "Meat":"소고기", "Mozzarella":"모짜렐라", "Mushroom":"양송이", "Napa":"배추", "None":"없음", "Paprika":"피망", "Perilla Leaf":"깻잎", "Pork":"돼지고기", "Potato":"감자", "Red Chili":"홍고추", "Red Paprica":"파프리카", "Red Pepper Paste":"고추장", "Sausage":"소시지", "Shiitake Mushroom":"표고버섯", "Shrimp":"새우", "Soybean":"된장", "Spam":"햄", "Tofu":"두부", "Tomato":"토마토", "Tuna":"참치", "Whelk":"골뱅이"] // 각 재료를 한국어로 변환해줄 Dictionary
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.output.text = ""
        // Do any additional setup after loading the view, typically from a nib.
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
        
        self.rectView.layer.borderColor = UIColor(red:0.00, green:0.70, blue:1.00, alpha:1.0).cgColor
        self.rectView.layer.borderWidth = 2
        self.rectView.layer.masksToBounds = true
        self.rectView.layer.cornerRadius = 5
        
        setupAVCapture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupAVCapture()
    }
    
    // 카메라를 위한 메소드
    func setupAVCapture() {
        // 카메라 시작
        // 카메라 동영상을 위한 AVCaptureSession 인스턴스 생성
        // An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
        let captureSession = AVCaptureSession()
        
    
        
        // 640 x 480 픽셀 사이즈로 캡쳐세션의 해상도를 설정한다.
        captureSession.sessionPreset = .vga640x480
        
        // 인풋을 주는 디바이스를 디폴트로 설정한다. ( 폰의 카메라, 동영상으로 설정 )
        guard let captureDevice =
            AVCaptureDevice.default(for: .video) else { return }
        
        // 위에서 정한 디바이스가 보내주는 카메라의 인풋
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // 인스턴스에 인풋을 추가해준다.
        captureSession.addInput(input)
        
        // AVCaptureSession을 시작한다.
        captureSession.startRunning()
        
        // 캡쳐하고 있는 비디오 화면을 보여주는 Vedio레이어
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // 비디오의 비율을 Layer에 꽉채우는 방식으로 설정한다.
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = viewForCamera.layer
        previewLayer.frame = rootLayer.bounds
        
        // 스토리 보드에서 미리 설정해 두었던 rootLayer에 서브레이어로 추가한다.
        
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
    
    
    
    // 새로운 캡쳐 이미지 아웃풋이 버퍼에 저장되면 호출되는 델리게이트 메소드
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Returns a sample buffer's CVImageBuffer of media data.
        // 매개변수로 받은 샘플버퍼를 리턴해준다.
        // 즉, 새로운 인풋이 입력되면 샘플버퍼를 매개변수로 하는 captureOutput 델리게이트 메소드가 실행되고
        // 매개변수로 받은 sampleBuffer를 CVPixelBuffer ( Core Video pixel buffer object. ) 에 할당해준다.
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 사용할 MLModel을 결정해준다.
        guard let model = try? VNCoreMLModel(for: NudgeMLModel10().model) else { return }
        
        //An image analysis request that uses a Core ML model to process images.
        // ML model을 사용한 이미지의 분석 요청
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // 에러 체크
            // print(finishedReq.results)
            
            // 분류된 이미지의 결과를 출력해주기 위해 results에 분석된 이미지 결과 할당
            // VNClassificationObsercation 은 mlmodel을 통해 인식된 물체를 String 값으로 반환해주는 타입.
            // 분석이 완료된 request를 VNClassficationObservation의 배열로 타입캐스팅을 해준다.
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            // 배열에서 가장 첫번째 값을 firstObservation이라고 한다.
            guard let firstObservation = results.first else { return }
            
            
            // 물체 인식률이 95%가 넘으면 지정한 배열에 추가해주고 결과값을 표시해주는 비동기 메인스레드
            DispatchQueue.main.async {
                // 인식률이 95%가 넘고
                if (firstObservation.confidence > 0.95)
                {
                    // 현재 hasIngredient에 포함되어있지 않고 None이 아니면
                    if( !self.hasIngredient.contains(String(firstObservation.identifier)) && (firstObservation.identifier != "None")
                        )
                    {
                        // 사용자가 인식 할 수 있도록 Str Label에 추가해준다.
                        self.hasIngredient.append(firstObservation.identifier)
                        //self.Str = self.Str + "\(firstObservation.identifier) "
                        self.Str = self.Str + "\(self.ingredient[firstObservation.identifier]!) "
                    }
                
                    self.output.text = self.Str
                }
                
                //self.object.text = "물체 : \(firstObservation.identifier)"
                self.object.text = "물체 : \(self.ingredient[firstObservation.identifier]!)"
                self.confidence.text = "정확도 : \(round(firstObservation.confidence*100)/100)"
                //round(avgTemp*100)/100
                
            }

        }
        // 이미지 분석 요청을 Array로 받아 관리한다.
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
    
    
    // 화면이 바뀌기전 수행되는 메소드
    // 다음 뷰컨트롤러로 인식된 hasIngredient ( 식재료 배열 ) 을 전달한다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientSegue" {
            
            // 화면을 전환해주기전 인식한 재료를 전달해준다.
            let IngredientInfo = segue.destination as? DetailViewController
            IngredientInfo?.hasIngredient = self.hasIngredient
        }
    }
    
}





