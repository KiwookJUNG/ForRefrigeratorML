//
//  DetailViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 07/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

class Ingredient { // Ingredient Class  재료의 이름과 선택됐는지 안됐는지 오프셋을 가진다.
    
    let name: String // 재료의 이름
    var isSelected: Bool = false // 선택됐는지 안됐는지 오프셋

    init(name: String) {
        self.name = name // 초기화 메소드
    }
}

class DetailViewController: UITableViewController  {
    
    // viewController에서 전해진 데이터
    var hasIngredient : [String] = []
    
    var switchCounter : Int = 0 // 재료가 1~5개가 벗어나면 오류창을 띠워주게 필요한 Count
    var ingredients: [Ingredient] = [] // Class를 인자로 가지는 배열 변수
    
    // 한국어로 번역하기위한 Dictionary
    var KoreanIngredient : [String : String] =  ["Bean Sprouts": "콩나물", "Broccoli":"브로콜리", "Cabbage":"양배추", "Carrot":"당근", "Chicken":"닭", "Chili":"고추", "Corn":"옥수수", "Crab":"꽃게", "Cucumber":"오이", "Daikon":"무", "Egg":"달걀", "Eggplant":"가지", "Garlic":"마늘", "Ginger":"생강", "Ginseng":"인삼", "Green Onion":"대파", "Jujube":"대추", "Kimchi":"김치", "Lettuce":"상추", "Mackerel":"고등어", "Manila Calm":"바지락", "Meat":"소고기", "Mozzarella":"모짜렐라", "Mushroom":"양송이", "Napa":"배추", "None":"없음", "Paprika":"피망", "Perilla Leaf":"깻잎", "Pork":"돼지고기", "Potato":"감자", "Red Chili":"홍고추", "Red Paprica":"파프리카", "Red Pepper Paste":"고추장", "Sausage":"소시지", "Shiitake Mushroom":"표고버섯", "Shrimp":"새우", "Soybean":"된장", "Spam":"햄", "Tofu":"두부", "Tomato":"토마토", "Tuna":"참치", "Whelk":"골뱅이"]
    var IVO : IngredientVO!
    
    
    override func viewDidLoad() {
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
    

        // hasIngredient는 ViewController에서 인식한 객채의 라벨을 전달받은 스트링 배열 변수이다.
        // 이 배열 변수에 있는 각 String 값을 for loop를 돌려 Ingredient Class를 초기화시켜 ingredients배열에 추가해준다.
        for i in hasIngredient {
            self.ingredients.append(Ingredient(name: "\(i)"))
        }
        
        
    }
    
    // 테이블뷰의 셀 갯수를 알려주는 델리게이트
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // hasIngredient에 들어있는 갯수만큼 테이블뷰의 셀 갯수가 할당된다.
        return self.hasIngredient.count
    }
    
    // 각 테이블 뷰 셀에 표시해야할 정보를 리턴해주는 델리게이트
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.hasIngredient[indexPath.row]
        
        // 테이블 뷰의 셀을 재사용 할 수 있도록 dequeue Reusable Cell로 만들어 준다.
        // 이렇게 되면 한번 사용한 셀을 재사용 할 수 있기 때문에 계속해서 새로운 셀을 만들어줄 필요가 없다.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell") as! IngredientCell
        
    
        // 재료의 이름을 라벨에, 스위치를 이용해 모든 값을 선택하지 않은 것으로 설정한다.
        cell.ingrdient.text = self.KoreanIngredient[row]
        cell.want.isOn = false
        
        // cell이 토글될때 마다 실행되는 메소드
        // Ingredient에 토글된 값이 표시된다 ( True OR False )
        
        cell.toggleHandler = { toggleSwitch in
            // toggleSwitch는 스토리보드에서 연결해준 액션변수이다.
            // 그러므로 스위치가 토글되면 함수가 실행되며 ON, OFF 값을 Ingredient 클래스의 isSelected에 저장해준다.
            self.ingredients[indexPath.row].isSelected = toggleSwitch.isOn
        }
        
        // 사용자가 switch를 선택 할 때마다 호출되는 메소드
        // switchCounter가 각각 토글될때 +하거나 -해준다.
        cell.want.addTarget(self, action: #selector(switched(_:)), for: .valueChanged)
        
        return cell
    }
    
    // 사용자가 선택을 하면 Count 값을 +1 해주고 사용자가 선택을 취소하면 -1 해준다.
    // swtich의 초기값은 0이다.
    @objc func switched(_ sender: UISwitch){
        if ( sender.isOn == true ) {
            switchCounter += 1
        } else {
            switchCounter -= 1
        }
        
        
    }

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
            
        } else if (self.switchCounter == 0){
            // 사용자가 재료를 선택하지 않으면 경고창을 띠워줌
            let title = "식재료를 선택해 주세요."
            let message = "식재료를 1개 이상 5개 이하로 선택해주세요."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: false)
        } else {
            // 사용자가 재료를 너무 많이 선택하면 경고창을 띠워준다.
            let title = "식재료가 너무 많습니다."
            let message = "식재료를 1개 이상 5개 이하로 선택해주세요."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: false)
        }
    }
    

    
    
    
}
