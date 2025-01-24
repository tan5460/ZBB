//
//  THFMDB.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/4/1.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import FMDB

class THFMDB: NSObject {
    
    //查询数据
    class func querySubData(_ parentId: String) -> Array<CityModel>? {
        
        let filePath = Bundle.main.path(forResource: "area", ofType: "sqlite")
        let db = FMDatabase.init(path: filePath)
        var cityArray: Array<CityModel> = []
        
        if db.open() {
            
            do {
                
                let rs = try db.executeQuery("SELECT * FROM yzb_area WHERE parent_id=?", values: [parentId])
                
                while rs.next() {
                    
                    let city = CityModel()
                    city.id = rs.string(forColumn: "id")
                    city.name = rs.string(forColumn: "name")
                    city.type = NSNumber.init(value: rs.int(forColumn: "type"))
                    
                    cityArray.append(city)
                }
                
                db.close()
                
                if cityArray.count > 0 {
                    return cityArray
                }else {
                    return nil
                }
                
            }catch {
                db.close()
                AppLog("数据库查询报错")
            }
        }
        
        return nil
    }
    
    
    
    
}

