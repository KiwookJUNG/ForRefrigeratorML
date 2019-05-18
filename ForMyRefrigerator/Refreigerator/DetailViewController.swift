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
    var KoreanIngredient : [String : String] =  ["Onion":"양파", "Egg":"달걀", "Green Onion":"대파", "Hairtail":"갈치", "Kimchi":"김치", "Mackerel" :"고등어", "Meat":"소고기", "Milk":"우유", "Pork":"돼지고기", "Red Pepper Paste": "고추장", "Soybean":"된장", "Tofu":"두부", "Tteok":"떡", "Cabbage":"양배추", "Carrot":"당근", "Chili":"고추", "Crushed Garlic":"다진 마늘", "Fish Cake":"어묵", "Green Pumpkin":"애호박", "Ham":"햄", "Manila Calm":"바지락",  "Sausage":"소세지",  "Garlic":"마늘", "Chicken":"닭고기"]

    
    
    override func viewDidLoad() {
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.14, green:0.35, blue:0.91, alpha:1.0)
    

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
        guard let collection = self.storyboard?.instantiateViewController(withIdentifier: "FoodCollection") as? ImageCollectionViewController else {
            return
        }
        
        if ( self.switchCounter < 6 && self.switchCounter > 0){
            
            let ingredientsSelected = ingredients.compactMap { $0.isSelected == true ? $0.name : nil }
            collection.ingredients = ingredientsSelected
            
            self.navigationController?.pushViewController(collection, animated: true)
            
        } else if (self.switchCounter == 0){
            let title = "식재료를 선택해 주세요."
            let message = "식재료를 1개 이상 5개 이하로 선택해주세요."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: false)
        } else {
            let title = "식재료가 너무 많습니다."
            let message = "식재료를 1개 이상 5개 이하로 선택해주세요."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: false)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "RecipeSegue" {
//
//            let imageViewCollectionViewController = segue.destination as? ImageCollectionViewController
//            let ingredientsSelected = ingredients.compactMap { $0.isSelected == true ? $0.name : nil }
//            
//            imageViewCollectionViewController?.ingredients = ingredientsSelected
//
//            
//        }
//    }

    func requestHttpPost(_ sender: Any){
        let json = ["재료1":self.hasIngredient[0],
                    "재료2":self.hasIngredient[1],
                    "재료3":self.hasIngredient[2],
                    "재료4":self.hasIngredient[3],
                    "재료5":self.hasIngredient[4]]
        // url 주소 할당
        guard let url = URL(string: "ec2-54-180-113-7.ap-northeast-2.compute.amazonaws.com") else { return }
        
        // http 설정 배열을 JSON 파일로 만들어준다.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch{
                    print(error)
                }
            }
        }.resume()
        
        
    }
    
    
}
