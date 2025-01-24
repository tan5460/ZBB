//
//  UtilOC.h
//  IQmoney
//
//  Created by 喻学文 on 16/1/26.
//  Copyright © 2016年 喻学文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface Utils_objectC : NSObject



+ (UIView *) animationView;  //检查银行卡是否正确
+ (BOOL)isMobileNumber:(NSString *)mobileNum;  //判断手机号码是否正确
+ (BOOL)isMobileNumber2:(NSString *)mobileNum;  //判断手机号码是否正确


@end
