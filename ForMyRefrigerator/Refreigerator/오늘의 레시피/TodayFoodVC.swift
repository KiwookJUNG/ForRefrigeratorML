//
//  TodayFoodVC.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 02/06/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

// 서버에서 받은 오늘의 레시피를 표시해주는 Collection View Controller

class TodayFoodVC : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var foodName : [String?] = []
    var foodImage : [String?] = []
    var counter : [String?] = []
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
        
    
        // API 호출을 위한 URI 생성
        let url = "http://0d29d1d4.ngrok.io/today"
        
        let apiURI: URL! = URL(string: url)
        
        // REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        
        do {
        // 받은 JSON 데이터를 Swift Native Data로 파싱
            let today = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSArray
            
        
        // Key 를 이요해서 데이터의 이미지와 요리 이름에 접근.
            for food in today {
                let f = food as! NSDictionary
                
                self.foodImage.append(f["dimage"] as? String)
                self.foodName.append(f["mname"] as? String)
                
               
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
           }
            
            
        } catch { }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as! TodayFoodCell
        
        //cell.foodImage.layer.masksToBounds = true
        //cell.foodImage.layer.cornerRadius = 5
        
        cell.todayFoodName?.text = self.foodName[indexPath.row]!
        
        let url: URL! = URL(string: row)
        
        let imageData : Data?
        
        if url != nil {
            imageData = try? Data(contentsOf: url)
        } else {
            imageData = nil
        }
       
        // 이미지를 비동기 방식으로 표시해준다.
        DispatchQueue.main.async(execute: {
            if imageData != nil {
                cell.todayFoodImage.image = UIImage(data: imageData!)
            } else {
                cell.todayFoodImage.image = UIImage(named: "no_image.png")
            }
        })
        
        return cell
    }

    
}
