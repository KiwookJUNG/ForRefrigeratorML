//
//  ImageCollectionViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 11/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    var foodImage : [String] = [] // 음식의 이미지를 저장해주는 배열 변수
    var foodName : [String] = [] // 음식의 이름을 저장해주는 배열 변수
    
    var ingredients : [String] = [] // 이전 ViewController(Detail View Controller로부터 제공받을 배열변수
    
    override func viewDidLoad() {
        // API 호출을 위한 URI 생성
        // 지금은 Open API이지만 이후, Server에서 제공해주는 우리만의 URL주소를 사용해서 POST HTTP 메소드를 보낼 예정
        let url = "http://openapi.foodsafetykorea.go.kr/api/6d82f3c09e2f4568b124/COOKRCP01/json/1/10"
        let apiURI: URL! = URL(string: url)
        
        // REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        do {
            // 받은 JSON 데이터를 Swift Native Data로 파싱
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            // JSON를 키를 이용해서 사용
            let cookrcp = apiDictionary["COOKRCP01"] as! NSDictionary
            let row = cookrcp["row"] as! NSArray
            
            // Key 를 이요해서 데이터의 이미지와 요리 이름에 접근.
            for food in row {
                let f = food as! NSDictionary
                
                self.foodImage.append(f["ATT_FILE_NO_MAIN"] as! String)
                self.foodName.append(f["RCP_NM"] as! String)
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
        
        
        let row = self.foodImage[indexPath.row]
        // 재사용 셀을 만들어준다.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
    
        
        cell.foodImage.layer.masksToBounds = true
        cell.foodImage.layer.cornerRadius = 5
        
        cell.foodName?.text = foodName[indexPath.row]
        
        // 이미지 데이터는 워킹스레드를 만들어 처리해준다.
        DispatchQueue.main.async(execute: {
            let url: URL! = URL(string: row)
            let imageData = try! Data(contentsOf: url)
            
            cell.foodImage.image = UIImage(data: imageData )
            
        })
       
        return cell
    }
    
}
