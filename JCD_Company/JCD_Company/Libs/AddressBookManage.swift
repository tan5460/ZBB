//
//  AddressBookManage.swift
//  YZB_Company
//
//  Created by liuyi on 2018/8/31.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Contacts

class AddressBookManage: NSObject {

    static let shared = AddressBookManage()
    
    //创建通讯录对象
    lazy var contactStore: CNContactStore = {
        let contactStore = CNContactStore.init()
        return contactStore
    }()
    
    func addContactName(name : String , phone : String) -> Bool {
        
        //创建CNMutableContact类型的实例
        let contactToAdd = CNMutableContact()
        
        //设置姓名
        contactToAdd.familyName = name

        //设置电话
        let mobileNumber = CNPhoneNumber(stringValue: phone)
        let mobileValue = CNLabeledValue(label: CNLabelPhoneNumberMobile,
                                         value: mobileNumber)
        contactToAdd.phoneNumbers = [mobileValue]
    
        //添加联系人请求
        let saveRequest = CNSaveRequest()
        saveRequest.add(contactToAdd, toContainerWithIdentifier: nil)
        
        do {
            //写入联系人
            try contactStore.execute(saveRequest)
            AppLog("保存成功!")
            return true
        } catch {
            AppLog(error.localizedDescription)
            return false
        }

    }
    
    func existPhone(phoneNum : String) -> Bool {

        // 创建联系人的请求对象
        // keys决定能获取联系人哪些信息,例:姓名,电话,头像等
        let fetchKeys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),CNContactPhoneNumbersKey] as [Any]
        let fetchRequest = CNContactFetchRequest.init(keysToFetch: fetchKeys as! [CNKeyDescriptor]);
        
        var isExist : Bool = false
        // 请求获取联系人
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: { ( contact, stop) -> Void in
                //获取姓名
                let lastName = contact.familyName
                let firstName = contact.givenName
                AppLog("姓名：\(lastName)\(firstName)")

                //获取电话号码
                for phone in contact.phoneNumbers {
                    //获得标签名（转为能看得懂的本地标签名，比如work、home）
                    var label = "未知标签"
                    if phone.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            phone.label!)
                    }
                    
                    //获取号码
                    let value = "\(phone.value)"
                    AppLog("\t\(label)：\(value)")
                    if phoneNum == value {
                        isExist = true
                    }
                }
                

            })
            
        }
        catch let error as NSError {
            AppLog(error.localizedDescription)
            return false
        }
       
     
        return isExist
    }
    
    //获取手机通讯录权限
    func authorizationWithSuccess(_ completionHandler: @escaping (_ : Bool, _ : Error?)->() ){
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            completionHandler(true, nil)
        }else {
            
            CNContactStore().requestAccess(for: .contacts) { (isAuthorize, error) in
                completionHandler(isAuthorize, error)
            }
        }
      
    }
    
}
