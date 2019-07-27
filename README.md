식재료 인식 및 레시피 추천 애플리케이션
==============================


1. 제공 서비스
2. 오늘의 레시피
3. 실시간 객체 인식 (Real Time Object Detection)
4. 실시간 객체 분류 (Real Time Object Classification)
5. 사용자 재료 선택
6. 레시피 추천 



# 1. 제공 서비스

### 서비스 설명

냉장고 속 **식재료**를 **Vision 프레임워크**를 사용하여 인식하고 

인식한 식재료를 바탕으로 서버로부터 **레시피**를 사용자에게 제공해주는 애플리케이션



### 서비스 화면

이미지 1 - 오늘의 레시피

이미지 2 - Object Detection

이미지 3 - Object Classification

이미지 4 - 레시피 추천







# 2. 오늘의 레시피



### 2 - 1. 화면 설명 

사용자 입장에서 애플리케이션 아이콘을 탭하면 보이는 가장 **첫 번째 화면**입니다.

서버로부터 받은 **임의의 레시피(요리 이미지, 요리 이름)** 을 사용자에게 보여주는 화면입니다.

사용자에게 오늘 추천해주고 싶은 레시피를 추천해주는 시스템을 구현하고자 하였습니다.

결과 화면은 다음과 같습니다.

### 2 - 2. 서버로부터 데이터 받아오기

가장 먼저 서버로 부터 데이터를 받아왔습니다.

```swift
        // API 호출을 위한 URI 생성
        let url = "http://f34b1d81.ngrok.io/today"
        
        let apiURI: URL! = URL(string: url)
        
        // REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)                               
```

`JSON` 데이터를 받아오기 위하여 서버로부터 제공받은 `url` 주소를 사용해 

차례로 `URL 객체`, `Data 객체`로 변환시켜줬습니다.



[ 전달 받은 JSON의 형태 - 이미지 6 ]

위와 같은 형태의 `JSON`을 전달 받았습니다.


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

`JSON 배열` 속에 `JSON 객체`가 있는 형태이므로,

`NSArray` 타입으로 캐스팅을 먼저 해주고 난뒤, 

키 값과 밸류 값이 있는 `JSON` 객체는 `NSDictionary`로 캐스팅 해주었습니다.


> **as! 를 이용하여 다운 캐스팅해준 이유** (JSONSerialization.jsonObject(with:option:) 구문은 Any 타입을 반환하므로 다운캐스팅이 필요합니다.)
>
> 서버에서 전달해주는 JSON의 형태가 변하지 않고 고정적이라고 생각해서 였습니다.
>
> 하지만, 예외적인 경우가 발생할 수 있고, 안정적인 코딩을 위해서는 as? 구문을 사용하여 옵셔널로 다운캐스팅 해주는 것이 더 바람직하다고 생각합니다.
>
> 반환된 옵셔널은 옵셔널 바인딩(guard let 또는 if let 을 사용하여 안전하게 옵셔널을 해제하는 방법)을 사용하여 옵셔널을 해제하여 사용할 수 있습니다.
>
> 반드시 다운 캐스팅이 성공할 것이라는 생각에 강제 해제 연산자인 !를 사용하였지만, as? 구문을 사용해서 다운 캐스팅 하는 것이 더 안전한 코딩 방식이라고 생각합니다.



### 2 - 3. 데이터를 받아온 후 발생한 문제

데이터를 받아 온 이후 자연스럽게 `protocol UICollectionViewDataSource` 에 구현되어 있는 델리게이트 메소드가 호출될 것이라고 예상했습니다.

하지만, `viewDidLoad`에 있는 코드 (위에서는 서버로 부터 받아온 `JSON`을 Native Data로 바꾸어 배열에 추가해주는 과정)가 끝나지 않아도

`protocol UICollectionViewDataSource`의 델리게이트 메소드가 호출되는 문제를 발견하였습니다.

그리하여, `print()`구문을 통해 델리게이트 메소드가 호출 될 때의 결과 값을 출력해본 결과

`collectionView(_:numberOfItemsInSection:)` 메소드에서의 리턴값 0을 출력하였습니다.

즉, `viewDidLoad`에 코드가 모두 끝나기전, 델리게이트 메소드가 호출되는 시점의 차이로 인해서 문제가 발생하였고,

`Collection View`에 아무것도 출력되지 않는 현상을 겪었습니다.

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

해경 방법 : 스토리 보드에서 `Collection View` 를 `@IBOutlet` 변수로 연결해 준 뒤
메인 스레드에서 비동기 방식으로 `reloadData()`를 실시해줬습니다.

- 이유 : 서버와 통신하는 하여 `JSON`을 `Native` 데이터로 바꿔주는 것이 네트워크 환경에 따라 다른 속도를 가질 수 있고 그에 따라 

`Datasource Delegate` 메소드가 호출되는 시점보다 `viewDidLoad`에서 데이터가 늦게 저장되므로 `reloadData()`를 비동기적으로 호출해주었습니다.
`reloadData()` 메소드를 사용하면 `Datasource Delegate`의 메소드가 재호출되기 때문입니다.

그러므로, for 구문 안에서 계속해서 이미지와 음식 `String` 값이 추가되는 동시에 `collectionView.reloadData()`를 실시해줬습니다.



### 2 - 4. 공부한 점 : 프로토콜의 필수 구현 명세

서버에서 전달 받은 데이터의 갯수(`Collection View Cell`이 몇개나 생성되어야 하는지 알기위해)를
 
파악하고 각 셀에 전달받은 데이터를 이용하여 `Collection View`에 출력시켜 주기 위해

`UICollcetionViewDataSource` 프로토콜을 채택하였습니다. 

`UICollectionViewDataSource`  프로토콜은 개발자 문서에 정의된 사항에 따르면 이 프로토콜을 채택한 객체는 반드시 `collectionView(_:numberOfItemsInSection:)` 메소드와 

`collectionView(_:cellForItemAt:)` 메소드를 구현해줘야 합니다. 이 메소드들은, 차례로 컬렉션 뷰 셀의 갯수를 리턴하고 각 셀에 출력해주는 역할을 합니다.

일반적으로 프로토콜을 구현할 때는 기본적으로 프로토콜의 명세에 포함된 모든 프로퍼티와 메소드, 그리고 초기화 구문을 구현해야 합니다.

그렇지 않으면 필요한 항목의 구현이 누락되었다는 오류가 발생하는데 여기서는 위의 두개의 메소드가 필수로 구현해야하는 메소드입니다.


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

- 위는 `UICollectionViewDataSource` 프로토콜의 정의 구문 중 일부 입니다. 가장 위의 두 메소드인 `collectionView(_:numberOfItemsInSection:)` 메소드와 
`collectionView(_:cellForItemAt:)` 메소드는 정의 구문인 func 앞에 아무런 구문도 붙어있지 않습니다.

 이렇게 되면 이 프로토콜을 채택한 객체는 반드시 두 메소드를 구현해줘야 프로토콜 명세에 맞춘 올바른 구현이라고 할 수 있습니다.

반면에, 가장 밑에 있는 `collectionView(_:viewForSupplementartElementOfKind:at:)` 메소드의 경우 `optional` 키워드가 붙어있습니다.

이러한 메소드는 프로토콜을 채택하더라도 반드시 구현해주지 않아도 됩니다.

그러므로 `optional func` 키워드가 붙은 프로토콜은 필요에 따라 구현 여부를 결정해 주면됩니다.



### 2 - 5. 공부한 점 : View Controller의 생명주기 - viewDidLoad가 호출되는 시점과 그 이후의 생명주기





# 3. 실시간 객체 인식 (Real Time Object Detection)

### 3 - 1. 캡쳐를 위한 카메라 구성 - AVFoundation Framework
### 3 - 2. CoreML과 Vision 프레임 워크를 사용한 실시간 객체 인식
### 3 - 3. 델리게이트 패턴


# 4. 실시간 객체 분류 (Real Time Object Classification)

### 4 - 1. 캡쳐를 위한 카메라 구성 - AVFoundation Framework
  - 실시간 객체 인식의 카메라 구성과 동일하여 생략 하였습니다.
### 4 - 2. CoreML과 Vision 프레임 워크를 사용한 실시간 객체 분류
  - 이 또한 실시간 객체 인식의 구성과 비슷하지만 차이점을 서술하겠습니다.
### 4 - 3. CALayer - ( View와 Layer의 관계 )
### 4 - 4. 인식한 식재료를 배열에 추가하기 - 프로젝트를 위해 필요한 부분 추가

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


# 5. 사용자 재료 

### 5 - 1. 재료와 오프셋 캡슐화
### 5 - 2. 사용자 선택 한 식재료 전달


# 6. 추천 레시피

### 6 - 1. 서버에 식재료 전송 (HTTP POST)
### 6 - 2. 결과 화면
# 6. 추천 레시피식잴
# 6. 추천 레시피
