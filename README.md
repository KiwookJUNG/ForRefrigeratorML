식재료 인식 및 레시피 추천 애플리케이션
==============================


1. [제공서비스](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#1-%EC%A0%9C%EA%B3%B5-%EC%84%9C%EB%B9%84%EC%8A%A4)
2. [오늘의 레시피](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#2-%EC%98%A4%EB%8A%98%EC%9D%98-%EB%A0%88%EC%8B%9C%ED%94%BC)
3. [실시간 객체 인식 (Real Time Object Detection)](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#3-%EC%8B%A4%EC%8B%9C%EA%B0%84-%EA%B0%9D%EC%B2%B4-%EC%9D%B8%EC%8B%9D-real-time-object-detection)
4. [실시간 객체 분류 (Real Time Object Classification)](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#4-%EC%8B%A4%EC%8B%9C%EA%B0%84-%EA%B0%9D%EC%B2%B4-%EB%B6%84%EB%A5%98-real-time-object-classification)
5. [사용자 식재료 선택](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#5-%EC%82%AC%EC%9A%A9%EC%9E%90-%EC%8B%9D%EC%9E%AC%EB%A3%8C-%EC%84%A0%ED%83%9D)
6. [레시피 추천](https://github.com/KiwookJUNG/ForRefrigeratorML/blob/iOSkiwook/README.md#6-%EC%B6%94%EC%B2%9C-%EB%A0%88%EC%8B%9C%ED%94%BC)

<br>
<br>



# 1. 제공 서비스

### 서비스 설명


냉장고 속 **식재료**를 **Vision 프레임워크**를 사용하여 인식하고 인식한 식재료를 바탕으로 서버로부터 **레시피**를 받아와 사용자에게 제공해주는 애플리케이션
<br>
<br>


### 서비스 화면

<div>
<img width="200" src="https://user-images.githubusercontent.com/47555993/61995613-ba2bf680-b0c5-11e9-86a5-31281bf664df.PNG"></img>
<img width="200" src="https://user-images.githubusercontent.com/47555993/61995608-b9936000-b0c5-11e9-916f-0ddcc7be7e61.PNG"></img>
<img width="200" src="https://user-images.githubusercontent.com/47555993/61995615-bac48d00-b0c5-11e9-9b70-552725e4c8ea.PNG"></img>
<img width="200" src="https://user-images.githubusercontent.com/47555993/61995614-ba2bf680-b0c5-11e9-9ef7-72095a335663.PNG"></img>
</div>

--------------------------
<br>
<br>
<br>


# 2. 오늘의 레시피



### 2 - 1. 화면 설명 

사용자 입장에서 애플리케이션 아이콘을 탭하면 보이는 가장 **첫 번째 화면**입니다.

서버로부터 받은 **임의의 레시피(요리 이미지, 요리 이름)** 을 사용자에게 보여주는 화면입니다.

사용자에게 오늘 추천해주고 싶은 레시피를 추천해주는 시스템을 구현하고자 하였습니다.

결과 화면은 다음과 같습니다.

<img width="300" src="https://user-images.githubusercontent.com/47555993/61995613-ba2bf680-b0c5-11e9-86a5-31281bf664df.PNG"></img>

<br>
<br>
<br>

### 2 - 2. 서버로부터 데이터 받아오기

가장 먼저 서버로 부터 데이터를 받아왔습니다.

```swift
        // API 호출을 위한 URI 생성
        let url = "http://f34b1d81.ngrok.io/today"
        
        let apiURI: URL! = URL(string: url)
        
        // REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)                               
```

- `JSON` 데이터를 받아오기 위하여 서버로부터 제공받은 `url` 주소를 사용해 차례로 `URL 객체`, `Data 객체`로 변환시켜줬습니다.

<br>
<br>
<img src="https://user-images.githubusercontent.com/47555993/61995617-bac48d00-b0c5-11e9-8d5f-60983f562da0.png"></img>


- 위와 같은 형태의 `JSON`을 전달 받았습니다.

<br>
<br>

```swift

        do {
        // 받은 JSON 데이터를 Native Data로 파싱
            let today = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSArray
            
        
        // Key 를 이용해서 데이터의 이미지와 요리 이름에 접근.
            for food in today {
                let f = food as! NSDictionary
                
                self.foodImage.append(f["dimage"] as? String)
                self.foodName.append(f["mname"] as? String)
           }
        } catch { }
```

- `JSON 배열` 속에 `JSON 객체`가 있는 형태이므로 `NSArray` 타입으로 캐스팅을 먼저 해주고 난뒤,  키 값과 밸류 값이 있는  `JSON 객체`는 `NSDictionary`로 캐스팅 해주었습니다.

<br>
<br>

> **as! 를 이용하여 다운 캐스팅해준 이유** (JSONSerialization.jsonObject(with:option:) 구문은 Any 타입을 반환하므로 다운캐스팅이 필요합니다.)
>
> 서버로 부터 전달받은 JSON의 형태가 변하지 않고 고정적이라고 생각해서 였습니다.
>
> 하지만, 예외적인 경우가 발생할 수 있고, 런타임 오류를 피하기위해서 as? 구문을 사용하여 옵셔널로 다운캐스팅 해주는 것이 더 바람직하다고 생각합니다.
>
> 반환된 옵셔널은 옵셔널 바인딩(guard let 또는 if let 을 사용하여 안전하게 옵셔널을 해제하는 방법)을 사용하여 옵셔널을 해제하여 사용할 수 있습니다.
>
> 반드시 다운 캐스팅이 성공할 것이라는 생각에 강제 해제 연산자인 !를 사용하였지만, as? 구문을 사용해서 다운 캐스팅 하는 것이 더 안전한 코딩 방식이라고 생각합니다.

<br>
<br>
<br>


### 2 - 3. 데이터를 받아온 후 발생한 문제

데이터를 받아 온 이후 자연스럽게 `protocol UICollectionViewDataSource` 에 구현되어 있는 델리게이트 메소드가 호출될 것이라고 예상했습니다.

하지만, `viewDidLoad`에 있는 코드 (위에서는 서버로 부터 받아온 `JSON`을 Native Data로 바꾸어 배열에 추가해주는 과정)가 끝나지 않아도 `protocol UICollectionViewDataSource`의 델리게이트 메소드가 호출되는 문제를 발견하였습니다.

그리하여, `print()`구문을 통해 델리게이트 메소드가 호출 될 때의 결과 값을 출력해본 결과 `collectionView(_:numberOfItemsInSection:)` 메소드에서의 리턴값 0을 출력하였습니다.

즉, `viewDidLoad`에 코드가 모두 끝나기전, 델리게이트 메소드가 호출되는 시점의 차이로 인해서 문제가 발생하였고, `Collection View`에 아무것도 출력되지 않는 현상을 겪었습니다.

<br>
<br>

```swift
@IBOutlet weak var collectionView: UICollectionView!


            for food in today {
                let f = food as! NSDictionary
                
                self.foodImage.append(f["dimage"] as? String)
                self.foodName.append(f["mname"] as? String)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
           }
```

- 해결 방법 : 스토리 보드에서 `Collection View` 를 `@IBOutlet` 변수로 연결해 준 뒤 메인 스레드에서 비동기 방식으로 `reloadData()`를 실시해줬습니다.

> **이유** : 서버와 통신하는 하여 `JSON`을 `Native` 데이터로 바꿔주는 것이 네트워크 환경에 따라 다른 속도를 가질 수 있고 그에 따라 
>
>`Datasource Delegate` 메소드가 호출되는 시점보다 `viewDidLoad`에서 데이터가 늦게 저장되므로 `reloadData()`를 비동기적으로 호출해주었습니다.
>`reloadData()` 메소드를 사용하면 `Datasource Delegate`의 메소드가 재호출되기 때문입니다.
>
>그러므로, for 구문 안에서 계속해서 이미지와 음식 `String` 값이 추가되는 동시에 `collectionView.reloadData()`를 실시해줬습니다.


<br>
<br>
<br>


### 2 - 4. 공부한 점 : 프로토콜의 필수 구현 명세

서버에서 전달 받은 데이터의 갯수(`Collection View Cell`이 몇개나 생성되어야 하는지 알기위해)를 파악하고 각 셀에 전달받은 데이터를 이용하여 `Collection View`에 출력시켜 주기 위해`UICollcetionViewDataSource` 프로토콜을 채택하였습니다. 

`UICollectionViewDataSource`  프로토콜은 개발자 문서에 정의된 사항에 따르면 이 프로토콜을 채택한 객체는 반드시 `collectionView(_:numberOfItemsInSection:)` 메소드와 `collectionView(_:cellForItemAt:)` 메소드를 구현해줘야 합니다. 
이 메소드들은, 차례로 컬렉션 뷰 셀의 갯수를 리턴하고 각 셀에 출력해주는 역할을 합니다.

일반적으로 프로토콜을 구현할 때는 기본적으로 프로토콜의 명세에 포함된 모든 프로퍼티와 메소드, 그리고 초기화 구문을 구현해야 합니다.
그렇지 않으면 필요한 항목의 구현이 누락되었다는 오류가 발생하는데 여기서는 위의 두개의 메소드가 필수로 구현해야하는 메소드입니다.

<br>
<br>

```swift
public protocol UICollectionViewDataSource : NSObjectProtocol {

    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int

    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell

    
    @available(iOS 6.0, *)
    optional func numberOfSections(in collectionView: UICollectionView) -> Int

    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
	
	. . .

}
```

- 위는 `UICollectionViewDataSource` 프로토콜의 정의 구문 중 일부 입니다. 

가장 위의 두 메소드인 `collectionView(_:numberOfItemsInSection:)` 메소드와 
`collectionView(_:cellForItemAt:)` 메소드는 정의 구문인 func 앞에 아무런 구문도 붙어있지 않습니다.

이 프로토콜을 채택한 객체는 반드시 두 메소드를 구현해줘야 프로토콜 명세에 맞춘 올바른 구현이라고 할 수 있습니다.

반면에, 가장 밑에 있는 `collectionView(_:viewForSupplementartElementOfKind:at:)` 메소드의 경우 `optional` 키워드가 붙어있습니다.

이러한 메소드는 프로토콜을 채택하더라도 반드시 구현해주지 않아도 됩니다.

그러므로 `optional func` 키워드가 붙은 프로토콜은 필요에 따라 구현 여부를 결정해 주면됩니다.
<br>
<br>
<br>


### 2 - 5. 공부한 점 : View Controller의 생명주기 - viewDidLoad가 호출되는 시점과 그 이후의 생명주기

`viewDidLoad`가 호출되는 시점은 개발자 문서에 따르면 컨트롤러의 뷰가 메모리에 로드되고 난 이후 호출됩니다. (Called after the controller’s view is loaded into memory.) 

즉, ‘뷰’가 만들어져서 메모리에 로드가 되고 난 이후에 호출되는 메소드로 뷰 컨트롤러의 생명주기 중 초기단계라고 할 수 있습니다. 

뷰 컨트롤러의 초기화에 관한 구문을 여기에 작성하면 됩니다.

<br>

￼<img width="550" alt="뷰컨생명주기" src="https://user-images.githubusercontent.com/47555993/61991477-98158280-b08b-11e9-96ad-e5aaae51d8eb.png">

[이미지 출처](https://developer.apple.com/documentation/uikit/uiviewcontroller?source=post_page)

<br>

뷰가 메모리에 로드되고 난 이후 뷰의 생명 주기는 위의 그림과 같습니다.

각각의 상태는 다음을 의미합니다.

**Appearing** : 뷰 컨트롤러가 스크린에 등장하기 시작한 순간부터 등장을 완료하기 직전까지의 상태, 
퇴장 중인 다른 뷰 컨트롤러와 교차하기도 하며, 이때 퇴장 중인 다른 뷰 컨트롤러의 상태는 Disappearing이 된다.

**Appeared** : 뷰 컨트롤러가 스크린 전체에 완전히 등장한 상태

**Disappearing** :  뷰 컨트롤러가 스크린에서 가려지기 시작해서 완전히 가려지기 직전까지의 상태, 또는 퇴장하기 시작해서 완전히 퇴장하기 직전까지의 상태. 
이 상태의 뷰 컨트롤러는 새로 등장할 뷰컨트롤러와 교차하기도 하며 이때 등장 중인 뷰 컨트롤러의 상태는 Appearing

**Disappeared** : 뷰 컨트롤러가 스크린에서 완전히 가려졌거나 혹은 퇴장한 상태

**Appearing** -> **Appeared** -> **Disappearing** -> **Disappeared**

--------------------------
<br>
<br>
<br>

# 3. 실시간 객체 인식 (Real Time Object Detection)

Vision 프레임워크를 사용해 머신러닝 모델로 객체를 인식하고 객체의 위치를 파악하여 사용자에게 어떤 식재료가 있는지 보여주는 화면입니다.

> **오픈소스 사용:** 오픈 소스를 이용한 AVCaputure와 CoreML - Vision 프레임 워크 사용
> [오픈소스 링크](https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture)

<br>
<br>

![디텍션지프](https://user-images.githubusercontent.com/47555993/61993927-4cc09b80-b0ae-11e9-8446-73655c01ef2a.gif)


<br>
<br>

### 3 - 1. 캡쳐를 위한 카메라 구성 - AVFoundation Framework


```swift
private let session = AVCaptureSession()
```

- `AVCaptureSession()`은 디바이스로 부터 들어오는 인풋부터 캡쳐 아웃풋까지 데이터의 흐름을 조직화하고 캡쳐활동을 관리하는 객체입니다.

<br>
<br>


<img width="583" alt="AVCaptureSession" src="https://user-images.githubusercontent.com/47555993/61991478-98158280-b08b-11e9-83b4-4dade062514a.png">


[이미지 출처](https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session)

- 위의 이미지는 `AVCaputureSession`에 관한 애플 개발자 문서에 수록된 이미지 입니다.

`AVCaputreSession`은 위의 그림과 같이 `디바이스(카메라 또는 마이크로폰)`으로 부터 `디바이스 인풋(Device Input)`을 받아와서 `아웃풋(Output)`으로 변환시키는 역할을 합니다.

위의 과정을 자세히 서술하자면 다음과 같습니다.

모든 `캡쳐 세션`은 적어도 하나의 `캡쳐 인풋{Input)`과 `아웃풋(Output)`이 있습니다. 

캡쳐 인풋은 대게 아이폰의 디바이스로 부터 들어오는 동영상이며 캡쳐 아웃풋은 그것을 가공한 비디오와 같은 것입니다.

<br>
<br>

```swift
	// 인풋을 위한 디바이스를 선택합니다.
        // 후면 카메라를 이용한 비디오를 AVCaputreDevice에 이용한다.
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
```

이러한 인풋을 사용하기위해서는 `AVCaputreDevice`를 통해 `AVCaputreSession` 객체에 사용될 디바이스를 등록해줘야 합니다.

<br>
<br>

```swift
	// Capture Input은 비디오 디바이스를 이용해 받는다.
        deviceInput = try AVCaptureDeviceInput(device: videoDevice!)

	// AVCaptureSession에 비디오를 이용한 캡쳐 인풋을 받을 수 있으면 추가해준다.
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
```

`AVCaptureDeviceInput(device:)` 메소드와 `addInput()`메소드를 사용하여 디바이스의 인풋을 캡쳐 세션에 등록해줍니다.

실시간 객체 인식을 하기 위해서는 `Video 데이터(아웃풋)`를 `큐`에 저장해야 합니다.

큐에 저장되면 `델리게이트 메소드`가 호출됩니다.

<br>
<br>

델리게이트 메소드인 

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
```

가 해주는 역할은 `AVCaputureSession`에 아웃풋(여기서는 큐)의 데이터를 파라미터로 받아서

Vision 프레임워크의 메소드들을 사용해 아웃풋에 적절한 처리를 거쳐서 결과 값을 리턴해주는 역할입니다.

<br>
<br>

그러기 위해서는 
```swift
	// DispatchQueue 는 work itmes들의 실행을 관리하는 객체. 각 work item 은 시스템이 관리하는 스레드들에 의해 큐잉됨.
    	// DispatchQueue의 Label을 "VidioDataOutput"으로 설정해준다.
    	private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
```

위와 같이 비디오 아웃풋을 관리하는 큐를 DispatchQueue를 사용하여 만들어줘야 합니다.

<br>
<br>

```swift
	if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // 캡쳐 세션에 비디오데이터 아웃풋을 추가해준다.
            videoDataOutput.alwaysDiscardsLateVideoFrames = true // 늦게 도착한 비디오 데이터를 버린다.
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            // 비디오데이터 아웃풋이 추가될때마다 호출되는 델리게이트 메소드의 버퍼를 추가해준다.
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        }
```

위의 코드는 세션에 비디오데이터 아웃풋을 `addOutput()` 메소드를 사용해 연결 해주고 그 비디오데이터 아웃풋 객체에 `setSampleBufferDelegate(_:queue:)` 메소드를 사용해 큐 버퍼와 델리게이트 객체를 등록해주는 과정입니다.

즉, 비디오 아웃풋에 동영상이 저장될 큐를 등록하여 세션에 등록해 준것 입니다.

그러면, 디바이스로 부터 들어오는 인풋은 캡쳐 세션에 의해 관리됩니다.

<br>
<br>

```swift
	let captureConnection = videoDataOutput.connection(with: .video)
```

`캡쳐 세션`은 `.connection(with:)`에 의해 연결된 데이터 아웃풋 버퍼로 인풋을 큐잉합니다.

아웃풋이 큐잉되면 `captureOutput(_:didOutput:from:)` 델리게이트 메소드가 호출되어 적절한 결과물로 변환되어

리턴됩니다. (ex) 머신러닝 모델을 이용한 분석 등)

<br>
<br>

> **정리 : AVCaputre 흐름** 
>
>1. 디바이스를 설정하고 디바이스의 인풋을 설정해줍니다.
>
>2. 디바이스의 인풋을 캡쳐 세션에 등록해 줍니다.
>
>3. 비디오 데이터 아웃풋(큐를 등록한) 또한 세션에 등록해 줍니다.
>
>4. 등록된 인풋과 아웃풋을 연결시켜줍니다. (addInput과 addOutput을 사용하면 대게 자동으로 connection이 일어납니다.)
>
>5. 캡쳐 세션이 시작되고 디바이스로 들어온 인풋은 캡쳐세션에 의해 관리됩니다.
>
>6. 인풋은 커넥션에 의해 아웃풋으로 전환되어 큐 버퍼에 저장됩니다.
>
>7. 아웃풋이 큐 버퍼에 저장되면 델리게이트 메소드가 실행되어 Vision 프레임워크의 메소드를 사용한 이미지 처리를 시작합니다.

<br>
<br>

### 3 - 2. CoreML과 Vision 프레임 워크를 사용한 실시간 객체 인식
앱에 내장된 `ML(Machine Learning) 모델`을 사용하여 캡쳐 세션에 있는 아웃풋 데이터를 분석하기 위하여 `Vision 프레임워크`를 사용하였습니다.

소스 코드에 대한 분석에 앞서, `CoreML`과 `Vision` 프레임워크에 대한 간략한 정리를 하겠습니다.

먼저, `CoreML 프레임워크`는 `머신러닝 모델`을 앱속에 결합시킬 수 있는 `프레임워크` 입니다.

<br>
<br>

<img width="477" alt="Core ML" src="https://user-images.githubusercontent.com/47555993/61991480-98158280-b08b-11e9-9f2f-00298c684b56.png">


￼[이미지 출처](https://developer.apple.com/documentation/coreml?source=post_page)



- `CoreML`은 위의 이미지와 같은 구조를 가집니다.

이미지 분석을 위해서 `CoreML`을 사용하기 위해서 지원되는 `프레임워크`는 `Vision 프레임워크` 입니다.

`CoreML`이 하는 역할은 디바이스에 내장된 머신러닝 모델을 최적화 하고 메모리와 파워의 소모를 최소화하는데 있습니다.

또한 `CoreML`을 사용하는 것에 대한 이점은 머신러닝 모델을 사용해 분석을 하기위해 서버와 통신을 하지 않아도 된다는 점에 있습니다.

이는, 서버와 통신하는 방법보다 즉각적인 분석과 서버에 대한 부하를 줄일 수 있고 유저의 데이터를 보호 할 수 있는등의 이점들로 설명할 수 있습니다.


`ML 모델`을 사용하여 `Vision 요청을 처리`해주는 것음 다음과 같은 방법으로 이루어 집니다.

<br>
<br>

```swift
let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
```

1. 머신러닝 모델 설정 : `VNCoreMLModel(for:)` 메소드를 사용하여 사용할 `ML 모델`을 설정해줍니다.



<br>
<br>

```swift
let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
    DispatchQueue.main.async(execute: {
        // perform all the UI updates on the main queue
        if let results = request.results {
            self.drawVisionRequestResults(results)
        }
    })
})
```

2. 이미지 분석 요청 등록 : `VNCoreMLRequest(model:completionHandler:)`를 이용해 설정된 `ML 모델`을 사용하여 이미지에 대한 `분석을 요청`합니다.


<br>
<br>


```swift
let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        }
```

3. 이미지 분석 요청 실행 : `VNImageRequestHandler.perform()`을 사용해 두 번째 과정에서 등록한 `요청(Request 배열)을 실행`시켜 줍니다.

1,2의 과정은 `Core ML`의 사용을 위한 `ML모델 등록` 및 `ML 모델을 사용한 이미지 분석 요청` 세팅입니다.

반면 3의 과정은 실제로 세팅된 모델과 요청을 사용하여 `이미지 분석을 실시`하는 과정입니다.

그러므로 3의 과정이 작성되어야할 곳은 

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
```

위치에 작성돼야 합니다.

왜냐하면, `captureOutput(_:didOutput:from:)` 메소드는 캡쳐 세션의 아웃풋이 저장되면 호출되는 델리게이트 메소드이고 아웃풋을 큐 버퍼로 관리하고 있습니다.

즉, 지속해서 아웃풋이 업데이트되며 계속해서 메소드가 호출되는 곳이므로 분석을 해야할 이미지가 파라미터로 들어옵니다. `(sampleBuffer)`

이 때문에, `VNImageRequestHandler`는 `cvPixelBuffer`를 파라미터로 받아 1,2에서 세팅했던 요청을 기반으로 버퍼에 있는 이미지를 분석할 수 있는 것입니다.

<br>
<br>


```swift
let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                
                // 비동기 메소드를 사용하여 들어오는 모든 요청의 바운딩 박스를 그려준다.
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
```

4. 이미지 분석 결과값, 사용 : `VNCoreMLModelRequest`가 `VNImageReqeustHandler.perform()`에 의해 실행된 결과는 `VNRecognizedOjbectObservation`의 타입으로 리턴됩니다.

위의 코드에서, `VNCoreMLRequest`는 `VNImageRequestHandler.perform()`에 의해서 실행됩니다.

이 때 `(request, error)` 를 매개변수로 가지는 클로져가 실행되는데 `results(배열)`은 `VNReucognizedObjectObservation` 타입의 배열입니다.

<br>
<br>

```swift
	for observation in results where observation is VNRecognizedObjectObservation
```

- 위의 코드는 `self.drawVisionRequestResults()`의 일부를 발췌한 것입니다.

이 메소드는 실행된 이미지 분석 요청의 결과 값 즉, `VNRecognizedObjectObservation`으로 바운딩 박스를 그려주는 메소드 입니다.

위에서 실행되는 for 루프는 `VNCoreMLRequest`의 결과 배열이 `VNRecognizedObjectObservation` 타입인지 아닌지를 판별한 후 맞으면 for 루프를 실행해주기 직전 단계입니다.

(즉, `VNRecognizedObjectObservation` 타입이면 바운딩 박스를 그려주기 직전 단계입니다.)

<br>
<br>
￼
<img width="1128" alt="Vision" src="https://user-images.githubusercontent.com/47555993/61991482-98ae1900-b08b-11e9-9084-782df2fc1fa3.png">
￼



￼[이미지 출처](https://developer.apple.com/videos/play/wwdc2017/506/)




- 위의 이미지는 이미지를 분석하는 `Vision 프레임워크`의 `워크 플로우` 입니다.

위에서 서술한 2번 부터 4번의 순서와 같이 ( 1번은 ML Model을 선택하는 과정이라 이미지에서는 제외돼있습니다.)

`MLMode을 사용한 요청(Request)` -> `요청 핸들러를 사용한 요청 실행(RequestHandler)` -> `결과값 반환(Observations)` 의 형태로 이루어 집니다.


> **정리 : 최종 흐름**
>
> `AVFoundation`과 `Vision` 프레임워크를 이용한 객체 인식의 전체 흐름은 다음과 같습니다.
> 
> 1. 카메라 세션 세팅 (디바이스, 인풋, 아웃풋 등록)
> 
> 2. ML Model 등록
> 
> 3. 이미지 분석 요청(Request) 등록
>
> 4. 세션 시작 -> 동영상이 등록했던 버퍼에 저장 됨
>
> 5. captureOutput(_:didOutput:from:) 델리게이트 메소드 실행
> 
> 6. 이미지 분석 실행(Request Handler)
> 
> 7. 이미지 분석 결과 값을 사용한 Bounding Box 그려주기

<br>
<br>

### 3 - 3. 델리게이트 패턴
<img width="785" alt="Delegate" src="https://user-images.githubusercontent.com/47555993/61991481-98ae1900-b08b-11e9-89be-3ce3f533ddb2.png">


￼[이미지 출처](https://www.oodlestechnologies.com/blogs/Brief-About-Delegation-Design-pattern-in-Swift/)

- 델리게이션은 위의 그림과 같이 `Object 1`이 처리할 수 있는 일을 `Object 2`에 위임하고 특정 이벤트가 발생하면 `Obejct 2`가 일을 처리해주는 것을 말합니다.

`Object 1`을 `일을 위임하는 객체`라고 하고 `Object 2`를 `델리게이트 객체`라고 합니다.

`Object 1`의 프로퍼티 중 하나(delegate 프로퍼티)를 `Object 2`를 참조할 수 있는 프로퍼티를 선언하고 `Object 2`를 참조하면 특정 이벤트가 발생하였을 때 `Object 2`에 구현된 메소드를 호출 할 수 있습니다.

그러므로 `Object 1`이 할 수 있는 일을 `Object 2`에 구현 해두고 필요한 시점에 호출할 수 있습니다.

즉, `하나의 객체(Object 1)`가 모든일을 처리하는 것이 아니라 처리해야 할일 중 일부를 `다른 객체(Object 2)`에 넘기는 것이 델리게이트 패턴입니다.

<br>
<br>

프로젝트에서는 동영상이 샘플 버퍼에 저장되는 이벤트가 일어날때 마다 이미지 처리 부분(`Vision 프레임워크를 사용한 이미지 분석`)을 다른 객체에 위임하여 동영상을 저장해주는 부분과 이미지를 처리해주는 부분을 나누어줬습니다.


![델리게이트](https://user-images.githubusercontent.com/47555993/62002818-1aaf4800-b147-11e9-98c5-f02419e48225.PNG)




위의 흐름을 코드로 설명하면 다음과 같습니다.

<br>
<br>

```swift
class CameraVC : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

// 비디오를 기록하고 비디오 프레임을 위한 프로세싱을 위한 접근을 제공하는 캡쳐 아웃풋
    private let videoDataOutput = AVCaptureVideoDataOutput()

	. . .

// DispatchQueue 는 work itmes들의 실행을 관리하는 객체. 각 work item 은 시스템이 관리하는 스레드들에 의해 큐잉됨.
    // DispatchQueue의 Label을 "VidioDataOutput"으로 설정해준다.
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

	. . .

	videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

}
```

먼저, `CameraVC` 뷰 컨트롤러는 `AVCaptureVideoDataOutput()`의 인스턴스를 가집니다.

이를 `videoDataOutput`이라고 한다면, `videoDataOutput`은 비디오를 기록하고 비디오 프레임을 위한 프로세싱을 위한 접근을 제공하는 객체입니다.

이 객체는 비디오가 저장이되는 객체이기 때문에 이에 해당하는 큐 버퍼가 필요합니다.

그러므로 두번째 줄은 데이터가 저장될 `DispatchQueue`를 만들어주는 코드입니다.

마지막 줄은 `videoDataOutput`의 객체가 해야 할일을 위임할 객체와 버퍼를 설정해주는 코드입니다.

`videoDataOutput`에 저장될 데이터를 받아줄 버퍼를 설정해 주고, `videoDataOutput` 대신에 일을 처리해줄 객체 (CameraVC를 의미합니다,)를 등록해주는 코드입니다.

이제, `videoDataOutput` 객체에 등록해준 버퍼에 동영상 데이터가 저장되는 순간 델리게이트로 지정한 객체에게 시스템은 이 사실을 알려줍니다.

<br>
<br>

```swift
class ObjectDetectionVC: CameraVC {

	. . .

	// 캡쳐 아웃풋이 샘플버퍼에 저장될 때 마다 실행되는 델리게이트 메소드
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }


} 
```

이벤트가 발생하면 `CameraVC 객체`(여기서는 `CameraVC`를 상속받은 `ObjectDetectionVC`가 처리합니다.) 는 이 사실을 알게되고 `videoDataOutput`에게 위임 받은 일을 처리 합니다. ( `captureOutput(_:didOutput:from:)` 메소드를 실행 함으로써 위임 받은 일을 처리 합니다,)

즉, `videoDataOutput`이 동영상 데이터를 저장하는 일과 동영상의 이미지를 분석하는 일 두가지를 나누어서 동영상의 이미지를 분석하는 일을 다른 객체에 위임을 한 것입니다.

코드에서는 `captureOutput(_:didOutput:from)` 메소드에서 `VNImageRequestHandler`가 미리 세팅된 요청을 실행해주는 역할을 하고 있습니다.

그러므로, 동영상이 버퍼에 저장되면 앞서 세팅되었던 이미지 분석 요청을 실행하는 일을 `videoDataOutput`이 하지않고 다른 객체(델리게이트 객체)에 위임해서 실시해주는 것입니다.

**이러한 델리게이트 패턴의 이점은 하나의 객체가 모든일을 처리하지 않기 때문에 기능 단위로 일을 나누기 쉽고 또한 시스템이 일을 처리해야할 시점을 알려주므로 간편하다는 장점이 있습니다.**



--------------------------
<br>
<br>
<br>

# 4. 실시간 객체 분류 (Real Time Object Classification)

![클래지프](https://user-images.githubusercontent.com/47555993/61995616-bac48d00-b0c5-11e9-8508-11726400cab5.gif)


Vision 프레임워크를 사용해 머신러닝 모델로 객체를 분류하고 사용자가 어떤 식재료가 있는지 화면을 통해 인식할 수 있도록 보여주는 화면입니다.

> **오픈소스 사용:** 오픈 소스를 이용한 AVCaputure와 CoreML - Vision 프레임 워크 사용
> [오픈소스 링크](https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml)

<br>
<br>

### 4 - 1. 캡쳐를 위한 카메라 구성 - AVFoundation Framework
  - 실시간 객체 인식의 카메라 구성과 동일하여 생략 하였습니다.

<br>
<br>

### 4 - 2. CoreML과 Vision 프레임 워크를 사용한 실시간 객체 분류
  - 이 또한 실시간 객체 인식의 구성과 비슷하지만 차이점을 서술하겠습니다.

<br>
<br>

```swift
        // 사용할 MLModel을 결정해준다.
        guard let model = try? VNCoreMLModel(for: NudgeMLModel10().model) else { return }
```

1. (공통점) 머신러닝 모델 설정 : `VNCoreMLModel(for:)` 메소드를 사용하여 사용할 `ML 모델`을 설정해줍니다.

<br>
<br>

```swift
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                        
        		. . .

        }
```
2. (공통점) 이미지 분석 요청 등록 : `VNCoreMLRequest(model:completionHandler:)`를 이용해 설정된 `ML 모델`을 사용하여 이미지에 대한 분석을 요청합니다.


<br>
<br>

```swift
        // 이미지 분석 요청 실행 시켜준다.
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
```
3. (공통점) 이미지 분석 요청 실행 : `VNImageRequestHandler.perform()`을 사용해 두 번째 과정에서 등록한 요청(Request 배열)을 실행시켜 줍니다.

<br>
<br>

```swift
// 분석이 완료된 request를 VNClassficationObservation의 배열로 타입캐스팅을 해준다.
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            // 배열에서 가장 첫번째 값을 firstObservation이라고 한다.
            guard let firstObservation = results.first else { return }
```

4. (차이점) 이미지 분석 결과값 사용 : `VNCoreMLModelRequest`가 `VNImageReqeustHandler.perform()`에 의해 실행된 결과는 `VNRecognizedOjbectObservation` 타입이 아니라 `VNClassificationObservation` 타입입니다.

왜냐하면 1번 ML 모델 설정 과정에서 ML 모델을 설정하는 과정은 공통적인 과정이었지만 실제로 선택한 ML 모델은 다른 모델이기 때문입니다.

<br>
<br>



<img width="907" alt="ObjectDetection" src="https://user-images.githubusercontent.com/47555993/61991681-c8aaeb80-b08e-11e9-8ae4-5d8a58d0bee4.png">


	- Turi Create 를 사용해서 만든 ML Model (Object Detection 용)

위의 그림은 프로젝트에 포함된 모델로 `Object Detection`을 위한 ML 모델입니다.

이 모델을 사용하여 이미지를 분석하면 두개의 `MultiArray` 아웃풋이 나옵니다.

따라서 이 모델을 사용하여 이미지를 분석한 결과값은 `VNRecognizedOjbectObservation` 타입이 됩니다.

<br>
<br>

<img width="907" alt="ObjectClassification" src="https://user-images.githubusercontent.com/47555993/61991673-97cab680-b08e-11e9-8ca2-1384370a8c66.png">

	- Create ML을 사용해서 만든 ML Model (Object Classification 용)

하지만 위의 두 번째 이미지는 `Object Classification`을 위한 ML 모델입니다.

이 모델을 사용하여 이미지를 분석하면 `Dictionary`와 `String` 타입의 아웃풋을 리턴합니다.

따라서 이 모델을 사용하여 이미지를 분석한 결과값은 `VNRecognizedOjbectObservation` 타입이 될 수 없고 `VNClassificationObservation` 타입이 됩니다.

이 처럼, **MLMode을 사용한 요청(Request) -> 요청 핸들러를 사용한 요청 실행(RequestHandler) -> 결과값 반환(Observations)**

실행의 흐름은 `Object Detection`과 똑같지만, 어떤 모델을 사용하였느냐에 따라 결과값 (`Observation`)이 달라지는 모습을 보여줍니다.

<br>
<br>

### 4 - 3. CALayer - ( View와 Layer의 관계 )

<div>
<img width="300"  src="https://user-images.githubusercontent.com/47555993/61995618-bb5d2380-b0c5-11e9-9885-87a0b0c83a8e.PNG">
<img width="300"  src="https://user-images.githubusercontent.com/47555993/61995619-bb5d2380-b0c5-11e9-9ebb-bc18cf69aa35.PNG">
</div>

위와 같이 카메라에 인식을 하면 물체의 라벨과 정확도가 나오는 화면입니다.

하지만 카메라가 비추는 화면만 보여주는 뷰는 사용자가 느끼기에 무엇을 인식 시켜야 하는지 어디에다가 인식시켜야 하는지 선뜻 이해하기 어려울 수 있기 때문에두 번째 이미지와 같이 파란색의 사각형의 `Layer`를 추가해줬습니다. 

그리고 `‘물체를 올려주세요.’`와 같은 사용자의 행동을 유도하는 라벨을 배치하였습니다.


<br>
<br>

#### 사각형의 Layer를 추가해주고자 할 때 발생한 문제

처음 사각형의 `Layer`를 추가해주기 위해 `UIView`를 만들고 `UIView`의 `layer`의 `border`의 색을 바꾼 후 `Root View`에 `addSubView`로 추가해주었습니다.

그러자 `Root View`에 서브뷰로 추가된 뷰 전체가 카메라 `Root View`의 `CALayer`를 가려서 백색의 화면만이 보이는 문제가 발생하였습니다.

문제를 분석해 본 결과 `Root View`에서 실제로 동영상 캡쳐를 디스플레이하는 것은 `UIView`가 직접 다루지 않고 `UIKit`에서 이러한 작업을 `Core Animation`에 위임하는 것으로 파악이 됐습니다.

실질적으로 뷰의 컨텐츠 여기서는 동영상 캡쳐를 디스플레이하는 이벤트는 `CALayer`가 담당하고 있었습니다.

<br>
<br>


```swift
let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
```

위의 구문의 `AVCaptureVideoPreviewLayer(session:)` 메소드는 비디오를 담당하는 캡쳐 세션을 이용하여 캡쳐된 비디오를 디스플레이 해주는 `Core Animation layer` 객체 입니다.

프로젝트에서 `Root View의 Root Layer`에 위의 객체(`previewLayer 객체`)를 서브레이어로 등록해 주었습니다.

그리고 난 다음 `Root View`에 새로운 `View( 파란색 사각형의 Layer를 가지는 View)`를 서브 뷰로 등록해주었더니 `Root View`의 `CALayer`를 서브뷰가 가리는 현상이 일어났습니다. 

<br>
<br>

#### 문제를 해결한 방법 : Root Layer에 Sub Layer로 추가하기.

```swift

let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

previewLayer.addSublayer(rectView.layer)

```
문제를 해결한 방법은 `Root Layer`를 가리지 않기 위해 `Root Layer`의 `Sub Layer`로 원하는 `Layer`를 추가해 줬습니다.

<br>
<br>

#### 공부한 점 : View와 CALayer의 관계


<img width="386" alt="CALayer" src="https://user-images.githubusercontent.com/47555993/61991479-98158280-b08b-11e9-9ba0-b7e4556326ab.png">


￼[이미지 출처](https://www.raywenderlich.com/402-calayer-tutorial-for-ios-getting-started)

`UIView`는 레이아웃을 설정하거나 사용자의 터치이벤트에는 반응하지만, 컨텐츠나 애니메이션을 그려주는 행위는 `Core Animation`에 위임하고 있습니다.

이러한 `Core Animation` 행위를 담당하는 것은 `UIView`가 감싸고 있는 `CALayer`가 담당 합니다. 즉, 동영상을 디스플레이 하는것을 담당하는 객체는 `CALayer` 객체이므로 새로운 `Layer`를 추가해주고 싶으면 `sublayer`방식으로 추가해 주어야 합니다.



<br>
<br>

### 4 - 4. 인식한 식재료를 배열에 추가하기 - 프로젝트를 위해 필요한 부분 추가

```swift
	let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
           
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
                      
                        self.outputStr = self.outputStr + "\(self.ingredient[firstObservation.identifier]!) "
                    }
                
                    self.output.text = self.outputStr
                }
                
                //self.object.text = "물체 : \(firstObservation.identifier)"
                self.object.text = "물체 : \(self.ingredient[firstObservation.identifier]!)"
                self.confidence.text = "정확도 : \(round(firstObservation.confidence*100)/100)"
                
            }

        }
```

위의 코드는 `VNCoreMLRequest` 부분 (이미지 분석 요청) 하는 부분에서 실제로 `Reuqest`가 실행되었을 때 실행되는 클로져입니다.

`VNCoreMLRequestHandler`에 의해 요청이 실행되면 클로져 또한 함께 실행되는데, 해당하는 클로저는 `VNClassificationObservation` 배열의 첫번째 결과 값이 일정 인식률(95%)를 넘으면 식재료가 인식되었다고 파악하고
`hasIngredient`라는 배열에 추가를 해주는 코드입니다.

그러므로, 사용자가 카메라를 통해 인식시킨 식재료가 95%의 정확도를 상회하면 인식된 식재료로 파악하고 인식된 식재료로 배열에 추가를 해줬습니다.


<br>
<br>


> **오픈 소스로 부터 공부한 점 : AVFoundation, Vision Framework, 델리게이트 패턴, CALayer** 
> 
>오픈 소스를 사용하면서 오픈 소스의 코드의 흐름과 논리의 흐름을 알지 못하고 사용하고 싶지 않았습니다.
>
>잘 알지 못하고 사용한다면 오픈 소스 내용을 토대로 다른 응용 코드도 짤 수 없고 더 발전도 할 수 없다고 생각했습니다. 
>
>그래서 오픈 소스를 사용하더라도, 코드에 대한 개략적인 이해와 프로그램의 흐름을 공부하고 난 뒤에 사용해야 한다고 마음 먹었습니다. 
>
>그리하여 동영상이 캡쳐 되면서 저장되고 그 이후 머신 러닝 모델을 통해서 이미지가 분석되는 코드의 흐름을 파악하고 각 코드가 왜 쓰였는지를 분석하면서 AVFoundation, Vision 프레임워크의 사용 흐름을 파악하였습니다. 
>
>또한 iOS 프로그래밍에서 많이 사용되는 델리게이트 패턴에 대한 심층적인 이해를 할 수 있었습니다. 
>
>마지막으로 평소 애플리케이션을 만들면서 많이 사용해 보지 못했던 CALayer에 대한 내용도 익힐수 있었습니다.

--------------------------
<br>
<br>
<br>


# 5. 사용자 식재료 선택

<div>
<img width="300" src="https://user-images.githubusercontent.com/47555993/61995611-ba2bf680-b0c5-11e9-9182-f2c0b4a5f789.PNG">
<img width="300" src="https://user-images.githubusercontent.com/47555993/61995612-ba2bf680-b0c5-11e9-96dc-d69a137a5092.PNG">
</div>

실시간 객체 인식 또는 객체 분류로 냉장고의 식재료를 인식한 다음 사용자에게 인식한 재료를 보여주는 뷰 입니다.

사용자는 **원하는 식재료**를 선택하고, 선택한 식재료를 다음 뷰 컨트롤러(사용자가 선택한 식재료를 서버로 보내고 그에 따른 레시피를 추천 받는 뷰 컨트롤러 입니다.) 로 넘겨주게 됩니다.

<br>
<br>

### 5 - 1. 재료와 오프셋 캡슐화


```swift
class Ingredient { // Ingredient Class  재료의 이름과 선택됐는지 안됐는지에 대한 오프셋을 가진다.
    
    let name: String // 재료의 이름
    var isSelected: Bool = false // 선택됐는지 안됐는지 오프셋

    init(name: String) {
        self.name = name // 초기화 메소드
    }

	. . .

}
```

`Ingredient` 클래스를 선언해 주었습니다.

왜냐하면 `Object Detection` 또는 `Object Classification`으로 인식된 재료가 이전 뷰 컨트롤러로 부터 `[String]` 배열로 전달 받았기 때문입니다.

전달 받은 `String` 식재료에 사용자가 선택하였는지에 대한 `오프셋(offset)`을 추가해 주기위해 클래스로 만들어 캡슐화 시켜줬습니다.

<br>
<br>

```swift
class DetailViewController: UITableViewController  {


	// 인식된 재료를 전달 받은 [String] 배열
    var hasIngredient : [String] = []

	var ingredients: [Ingredient] = [] // Class를 인자로 가지는 배열 변수

	
	override func viewDidLoad() {
        
        for i in hasIngredient {
            self.ingredients.append(Ingredient(name: "\(i)"))
        }  
    }


}
```

위의 코드를 사용하여, 전달 받은 식재료를 `offset`을 추가한 `Ingredient` 타입의 배열에 추가해 주었습니다.

<br>
<br>

### 5 - 2. 사용자 선택 한 식재료 전달

```swift
class IngredientCell: UITableViewCell {

    @IBOutlet weak var ingrdient: UILabel!
    
    @IBOutlet weak var want: UISwitch!
    
    var toggleHandler: ((UISwitch) -> Void)?
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        toggleHandler?(sender)
    }
}
```


각각의 테이블 뷰 셀에 위치한 `switch`가 `on/off` 될때마다 `Ingredient offset`을 업데이트 해주기위해 커스템 셀을 만들었습니다.

스토리보드에서 연결해준 `@IBAction` 메소드인 `toggleSwitch`는 `on/off` 될때마다 `UISwitch`를 파라미터로 가지는 메소드타입의 `toggleHandler` 프로퍼티가 실행됩니다.

<br>
<br>

```swift
// 각 테이블 뷰 셀에 표시해야할 정보를 리턴해주는 델리게이트 메소드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		. . . 
        
        // Ingredient에 토글된 값이 표시된다 ( True OR False )
        
        cell.toggleHandler = { toggleSwitch in
            // toggleSwitch는 스토리보드에서 연결해준 액션변수이다.
            // 그러므로 스위치가 토글되면 함수가 실행되며 ON, OFF 값을 Ingredient 클래스의 isSelected에 저장해준다.
            self.ingredients[indexPath.row].isSelected = toggleSwitch.isOn
        }
           
        return cell
    }
```

`toggleHandler`는 위와 같이 클로져로 구현하였습니다.

`toggleHandler`의 클로저는 각 셀의 `Switch`가 `on/off` 될때 마다 실행되는 값입니다.

`on/off`가 된 `offset( True Or False )`의 값을 해당하는 식재료의 `offset`에 해당하는 `isSelected`값에 대입해줬습니다.

<br>
<br>

```swift
@IBAction func alertCount(_ sender: Any) {
        
        // FoodCollection( ViewController)로 정보를 전달하기 위해 뷰컨트롤러의 인스턴스를 읽어온다.
        guard let collection = self.storyboard?.instantiateViewController(withIdentifier: "FoodCollection") as? ImageCollectionViewController else {
            return
        }
        
        // 사용자가 1~5개의 재료를 선택하면
        if ( self.switchCounter < 6 && self.switchCounter > 0){
            
            
            // ingredients 배열에 있는 값들을 순회하면서 isSeleted값이 true이면,
            // 즉, 사용자가 선택한 재료라면 다음 뷰컨트롤러로 넘겨준다.
            // 
            let ingredientsSelected = ingredients.compactMap { $0.isSelected == true ? KoreanIngredient[$0.name] : nil }
            collection.ingredients = ingredientsSelected
            
            
            self.navigationController?.pushViewController(collection, animated: true)
             
        }
} 
```

`alertCount` 액션 메소드는 사용자가 선택한 식재료가 1~5개 사이일 때 `Ingredient`의 인스턴스를 배열로 가지는 `ingredients` 배열을 `compactMap`으로 선택된 값만 선택하여 배열로 만들어주는 함수를 사용해 새로운 `String 배열`을 만들어 다음 뷰 컨트롤러로 전달하였습니다.

`compactMap(_:)` 메소드는 호출하는 배열에서 `nil`이 아닌 값들 만을 모아 새롭운 배열을 리턴해주는 메소드입니다.

인자로 클로저가 들어갈 수 있으므로 클로저가 실행된 뒤 `compactMap`이 실행됩니다.

그러므로, 위의 코드에서는 각 배열의 요소에서 `isSelected` 값이 `true`이면 재료 이름을 그렇지 않으면 `nil` 값을 만드는 새로운 배열을 생성한 후 이후 `compactMap`으로 `nil` 값을 전부 제거해주는 것 입니다.

이렇게 되면, 사용자가 선택한 식재료만을 다음 뷰 컨트롤러에 넘겨 줄 수 있게 됩니다.


--------------------------
<br>
<br>
<br>

# 6. 추천 레시피

사용자가 선택한 식재료를 서버에 전송하고 그에 따른 레시피를 받아와 출력해주는 화면입니다.

결과 화면은 다음과 같습니다.

<img width="300" src="https://user-images.githubusercontent.com/47555993/61995614-ba2bf680-b0c5-11e9-9ef7-72095a335663.PNG">

<br>
<br>

### 6 - 1. 서버에 식재료 전송 (HTTP POST)

사용자가 앞선 화면에서 식재료를 선택하였다면 식재료를 `HTTP POST` 방식으로 서버에 전송하고 그에 따른 결과물을 받아 출력해주려고 하였습니다.

```swift
class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
  	. . .
    
    var ingredients : [String] = [] // 이전 ViewController(Detail View Controller로부터 제공받을 배열변수
    
    override func viewDidLoad() {
        
        // 사용자가 선택한 ingredients 배열 ( 식재료 String 배열 )을 JSON으로 바꿔준다.
        let postJson = ingredients.reduce([String:String]()) { (result, ingredient) -> [String: String] in
            var result = result
            var num = 1
            for ing in ingredients{
                let keyString = "ING" + "\(num)"
                result[keyString] = ing
                num = num + 1
            }
            return result
        }
	
 		. . .
	}

}
```

`var ingredients : [String]` 프로퍼티는 앞의 뷰 컨트롤러에서 사용자가 선택한 식재료를 전달받은 배열 변수 입니다.

서버에 `HTTP POST` 방식으로 전달하기 위해서는 `JSON` 형태로 바꿔줘야 합니다.

그러므로 `ingredients` 배열을 `JSON`으로 바꾸기 위해 `키`와 `value` 형태인 딕셔너리로 먼저 바꾸어줬습니다.

<br>
<br>

```swift
// HTTP Body는 postJson ( 위에서 만들어 줬던 JSON ) 으로 할당해준다.
        guard let httpBody = try? JSONSerialization.data(withJSONObject: postJson, options: []) else { return }

        request.httpBody = httpBody
``` 

이후 딕셔너리로 변환된 `postJson` 프로퍼티를 `JSONSerialization.data(withJSONObject:options:)` 메소드를 이용해 `JSON` 형식으로 바꾸어 준 후 서버에 전송하였습니다.

나머지의 과정은 `오늘의 레시피`와 똑같은 과정을 거쳐 화면에 디스플레이 해줬습니다.


