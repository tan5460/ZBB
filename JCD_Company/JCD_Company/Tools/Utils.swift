//
//  Util.swift
//  ShiXue
//
//  Created by 钟广祥 on 15/7/4.
//  Copyright (c) 2015年 钟广祥. All rights reserved.
//

import UIKit
import Foundation

///常用类
struct Utils {
    /// 判断设备是否模拟器
    static var isSimulator: Bool {
        get {
            var isSim = false
            #if arch(i386) || arch(x86_64)
            isSim = true
            #endif
            return isSim
        }
    }
    
    /// 根据某个字段值获取[NSDictionary]中的另外一个字段值
    static func getFieldValInDirArr(arr: [NSDictionary], fieldA: String, valA: String, fieldB: String) -> String {
        
        var valBStr = "未知"
        
        for i in arr {
            
            let valAStr = getReadString(dir: i, field: fieldA)
            
            if valAStr == valA {
                
                valBStr = (i.object(forKey: fieldB) as? String) ?? ""
                break
            }
        }
        
        return valBStr
    }
    
    /// 根据某个字段值获取[NSDictionary]中的值数组
    static func getFieldArrInDirArr(arr: [NSDictionary], field: String) -> [String] {
        
        var relArr:[String]=[]
        
        for i in arr {
            
            let valueStr = getReadString(dir: i, field: field)
            relArr.append(valueStr)
        }
        
        return relArr
    }
    
    /// 获取请求数据中的数组数据
    static func getReqArr(data: AnyObject) -> NSArray {
        let array = getReadArr(data: data as! NSDictionary,field:"data")
        return array
    }
    
    /// 获取请求数据中的数组数据
    static func getReqSArr(data: AnyObject) -> NSArray {
        
        let resultData = getReadDic(data: data, field: "body")
        let array = getReadArr(data: resultData,field:"specData")
        return array
    }
    
    /// 获取请求数据中的字典数据
    static func getReqDir(data: AnyObject) -> NSDictionary {
        let dic = getReadDic(data: data, field: "data")
        return dic
    }
    
    /// 读取字典中的数组
    static func getReadArr(data: NSDictionary, field: String) -> NSArray {
        
        var resultArr: NSArray = []
        
        if let value = data.object(forKey: field) as? NSArray {
            
            resultArr = value
        }
        
        return resultArr
    }
    
    /// 读取数据中的字典数组
    static func getReadArrDic(data: NSDictionary, field: String) -> [NSDictionary] {
        
        var resultArr:[NSDictionary] = []
        
        if let value = data.object(forKey: field) as? [NSDictionary] {
            
            resultArr = value
        }
        
        return resultArr
    }
    
    /// 读取数据中的字典
    static func getReadDic(data: AnyObject, field: String) -> NSDictionary {
        
        var resultDic:NSDictionary=[:]
        
        if let value = data.object(forKey: field) as? NSDictionary {
            
            resultDic = value
        }
        
        return resultDic
    }
    
    /// 读取字典中的字符串
    static func getReadString(dir: NSDictionary, field: String, val: String="", suffix: String="") -> String {
        
        var str = val
        
        if let value = dir.object(forKey: field) as? NSNumber {
            
            str = "\(value)" + suffix
            
        }else if let value = dir.object(forKey: field) as? String {
            
            str = value + suffix
        }
        
        return str
    }
    
    /// 读取字典中的整数Int
    static func getReadInt(dir: NSDictionary, field: String, val: Int=0) -> Int {
        
        var rel = val
        
        if let value = dir.object(forKey: field) as? NSNumber {
            
            rel = value.intValue
            
        }else if let value = dir.object(forKey: field) as? String {
            
            rel = Int(value) ?? val
        }
        
        return rel
    }
    
    /// 读取字典中的Float
    static func getReadCGFlaot(dir: NSDictionary, field: String, val: CGFloat=0) -> CGFloat {
        
        var rel = val
        
        if let value = dir.object(forKey: field) as? NSNumber {
            
            rel = CGFloat(value.floatValue)
            
        }else if let value = dir.object(forKey: field) as? String {
            
            rel = CGFloat(Float(value) ?? Float(val))
        }
        
        return rel
    }
    
    /// 读取字典中的Double
    static func getReadDouble(dir: NSDictionary, field: String, val: Double=0) -> Double {
        
        var rel = val
        
        if let value = dir.object(forKey: field) as? NSNumber {
            
            rel = value.doubleValue
            
        }else if let value = dir.object(forKey: field) as? String {
            
            rel = Double(value) ?? val
        }
        
        return rel
    }
}
