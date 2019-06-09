//
//  ImageCollectionViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 11/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

// 사용자가 선택한 재료를 POST 방식으로 서버에 HTTP 메세지를 보낸 뒤, 응답을 받아 ( Image, Label ) Collection형태로 디스플레이해준다.

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    var foodImage : [String?] = [] // 음식의 이미지를 저장해주는 배열 변수
    var foodName : [String?] = [] // 음식의 이름을 저장해주는 배열 변수
    @IBOutlet weak var collectionview: UICollectionView!
    
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

        // URL 주소를 할당하고
        guard let url = URL(string: "http://0d29d1d4.ngrok.io/recipes") else { return }

        var request = URLRequest(url: url)
        
        // HTTP Header를 설정한다.
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // HTTP Body는 postJson ( 위에서 만들어 줬던 JSON ) 으로 할당해준다.
        guard let httpBody = try? JSONSerialization.data(withJSONObject: postJson, options: []) else { return }

        request.httpBody = httpBody

        // HTTP 요청을 보낸다.
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            // POST요청으로 받은 Data를 json 형식에서 Swift Naive ( String ) 으로 변환 후 각 배열에 추가한다
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    for food in json {
                        let f = food as! NSDictionary
                        self.foodImage.append(f["dimage"] as? String)
                        self.foodName.append(f["mname"] as? String)
                    }
                } catch{
                    print(error)
                }
            }
            // Collection view를 리로드 한다.
            // 왜냐하면, Collection view의 Delegate가 호출되는 시점이 POST요청으로 부터 데이터를 다시 받는 시점 보다 빠르기 때문에 Delegate가 다시호출되도록 Collection view 를
            // Reload 해준다.
            DispatchQueue.main.async {
                self.collectionview.reloadData()
            }
        }.resume()

    }
 
    // Collection 의 Cell 갯수를 리턴해주는 델리게이트 객체
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // CollectionView 의 셀의 갯수를 FoodName 의 있는 갯수만큼 생성해야한다.
        return self.foodName.count
        
    }
    
    // 각 셀에 표시해줄 데이터
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let row = self.foodImage[indexPath.row]!
        // 재사용 셀을 만들어준다.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
    
        
        cell.foodImage.layer.masksToBounds = true
        cell.foodImage.layer.cornerRadius = 5
        
        cell.foodName?.text = foodName[indexPath.row]!
        
        let url: URL! = URL(string: row)
        
        // try?을 통해 url을 Data를 통해 열었지만 열수없을 경우 nil을 리턴해준다.
        let imageData = try? Data(contentsOf: url)
    
       
        // imageData가 nil 이면 noImage를 그렇지 않으면 collection view 에 디스플레이 해준다.
        DispatchQueue.main.async(execute: {
            //cell.foodImage.image = UIImage(data: imageData)
            if imageData != nil {
                cell.foodImage.image = UIImage(data: imageData!)
            } else {
                cell.foodImage.image = UIImage(named: "no_image.png")
            }
        })
       
        return cell
    }
    
    
    // collection view 가 선택됐을 때, 화면을 전환해준다
    // 화면을 전환해주기 전, 사용자가 선택한 음식 이미지와 이름을 다음 뷰 컨트롤러로 전달해준다.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let recipe = self.storyboard?.instantiateViewController(withIdentifier: "Recipe") as? RecipeVC else {
            return
        }
        
        let name = self.foodName[indexPath.row]
        let image = self.foodImage[indexPath.row]
        
        recipe.foodName = name
        recipe.foodImage = image
        
        self.navigationController?.pushViewController(recipe, animated: true)
        
    }
    
}
