//
//  RecipeVC.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 02/06/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

// 사용자가 선택한 요리의 레시피를 표시해주는 뷰 컨트롤러
class RecipeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 사용자가 선택한 요리를 표시해주는 이미지뷰 아울렛 변수
    @IBOutlet weak var image: UIImageView!
    // 요리 순서를 표시해주는 view
    @IBOutlet weak var viewLayer: UIView!
    // 요리 순서가 디스플레이되는 collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 요리 순서와 이미지가 있는 Direction Struct
    struct Direction {
        var order : Int = 0
        var direction : String?
        var directionImage : String?
    }
    
    // 사용자가 선택한 foodImage와 foodName을 저장하는 변수
    var foodImage : String?
    var foodName : String?
    
    //POST로 받은 Direction의 Struct를 저장하는 구조체 배열
    var recipeDirection : [Direction] = []
    
    // JSON으로 만들기전 배열을 먼저 만들 딕셔너리
    var postJson = [String : String]()
    
    
    
    override func viewDidLoad() {
        
        // 네비게이션 바에 사용자가 선택한 요리를 표시해준다.
        self.navigationItem.title = foodName!
        
        // image View에 사용자가 선택한 요리이미지를 보여준다.
        let imageUrl: URL! = URL(string: self.foodImage!)
        
        let imageData = try? Data(contentsOf: imageUrl)
        
        if imageData != nil {
            self.image.image = UIImage(data: imageData!)
        } else {
            self.image.image = UIImage(named: "no_image.png")
        }
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 59))
        view.layer.borderColor = UIColor(red:0.51, green:0.69, blue:0.80, alpha:1.0).cgColor
        view.layer.borderWidth = 1.0
        viewLayer.addSubview(view)
        
        
    
        // JSON 을 만들기전 Dictionary를 만들어주고
        self.postJson["foodName"] = self.foodName!
        
        // POST요청을 보낼 url을 할당
        guard let url = URL(string: "http://0d29d1d4.ngrok.io/choice-menu") else { return }
        
        // http 설정 배열을 JSON 파일로 만들어준다.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: postJson, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    for food in json {
                        var dir = Direction()
                        
                        let f = food as! NSDictionary
                        
                        // POST 요청을 보낸 뒤 받은 데이터를 구조체 배열에 저장해준다.
                        
                        dir.direction = f["direction"] as? String
                        dir.directionImage = f["dir_image"] as? String
                        dir.order = f["dirkey"] as! Int
                        
                        // 구조체를 배열에 추가해준다.
                        self.recipeDirection.append(dir)
                    
                    }
                } catch{
                    print(error)
                }
            }
            // collection view Delegate가 호출되는 시기와 Data를 받는 시기의 차이가 있으므로 reload Data를 해준다.
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            }.resume()
        
    }
    
    // 배열의 갯수만큼 collection 뷰를 표시해준다.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipeDirection.count
    }
    
    // collection view cell에 표시될 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = self.recipeDirection[indexPath.row]
        
        // 만약 요리 순서에 이미지가 없으면 이미지가 없는 셀을 이미지가 있으면 이미지가 있는 셀을 선택한다.
        let cellId = row.directionImage == nil ? "direction" : "directionWithImage"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RecipeCell
        
        cell.direction.text = row.direction!
        cell.direction.sizeToFit()
        
        if(row.directionImage != nil)
        {
            let imageUrl = row.directionImage!
            let url: URL! = URL(string: imageUrl)
            let imageData = try? Data(contentsOf: url)
        
        
            DispatchQueue.main.async(execute: {
                //cell.foodImage.image = UIImage(data: imageData)
                if imageData != nil {
                    cell.directionImage.image = UIImage(data: imageData!)
                    cell.directionImage.sizeToFit()
                } else {
                    cell.directionImage.image = UIImage(named: "no_image.png")
                }
            })
        }
        
        return cell
    }
    
 
    
    
}
