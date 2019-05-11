//
//  ImageCollectionViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 11/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    var foodImage : [String] = []
    var foodName : [String] = []
    
    override func viewDidLoad() {
        // API 호출을 위한 URI 생성
        let url = "http://openapi.foodsafetykorea.go.kr/api/6d82f3c09e2f4568b124/COOKRCP01/json/1/10"
        let apiURI: URL! = URL(string: url)
        
        // REST API를 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            let cookrcp = apiDictionary["COOKRCP01"] as! NSDictionary
            let row = cookrcp["row"] as! NSArray
            
            for food in row {
                let f = food as! NSDictionary
                
                self.foodImage.append(f["ATT_FILE_NO_MAIN"] as! String)
                self.foodName.append(f["RCP_NM"] as! String)
            }
            
        } catch { }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.foodName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let row = self.foodImage[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.foodName?.text = foodName[indexPath.row]
        
        DispatchQueue.main.async(execute: {
            let url: URL! = URL(string: row)
            let imageData = try! Data(contentsOf: url)
            
            cell.foodImage.image = UIImage(data: imageData )
            
        })
       
        return cell
    }
    
}
