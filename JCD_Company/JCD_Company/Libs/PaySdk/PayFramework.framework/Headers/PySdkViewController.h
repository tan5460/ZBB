//
//  PySdkViewController.h
//  PayFramework
//
//  Created by 陈小瑞 on 2020/8/30.
//  Copyright © 2020 crx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayFramework/XHPayParameterModel.h>

NS_ASSUME_NONNULL_BEGIN
 

 

@interface PySdkViewController : UIViewController

/// 报错信息 message   支付类型typeStr 5 种
@property (nonatomic, copy) void(^payfailureBlock)(NSString *errorMessage,NSString *typeStr);
 

/// 根据typeStr  区分各种支付的类型 获取相应的支付参数返回
/// 对应关系如下 typeStr
///  unionpays   --- 银联 - - -TN             传给银联SDK
///  sandpays   --- 杉德宝 - - -TN             传给杉德宝SDK
///  linkpays   --- 链接支付 - - -link string  直接在支付宝微信等好友发送打开
///  alipays   --- 支付宝 - - - - tokenId             用来查询支付结果 必要参数
///  wxpays   ---  微信 - - -tokenId                  用来拼接在小程序路径后面

@property (nonatomic, copy) void(^payTypeBlock)(NSString *typeStr,NSString *tokenID);
 
  





/// 可以根据业务 5合一 包含银联支付，支付宝支付，微信支付 链接好友支付 杉德宝支付
///    注意⚠️  如果接入多合一支付  需要全部参数都要传 必要参数不可传""，例如接入微信支付但是没有传微信的参数,支付页面会显示微信支付方式但是无法吊起微信支付。
///  @param model 支付方式 多个就支持多种 一个就支持一种  微信02010005 支付宝02020004  银联02030001  链接02000002 杉德宝02040001  例如：product_code =  @"02000002,02010005,02020004,02030001,02040001"
-(void)requestMultiplePayWithModel:(XHPayParameterModel*)model;

 

/// 粘贴板链接好友支付
/// @param model 参数模型 model.product_code = @"02000002"
///  model.linkTips 粘贴成功提示语 不填默认 弹出 复制成功
-(void)linkToPayWith:(XHPayParameterModel*) model;
 

/// 杉德宝SDK支付 用户接入杉德宝支付 注意⚠️需要把自己的app的bundle id 加在在url type中
/// @param model 参数 model.product_code = @"02040001"
-(void)sandBaoPayWith:(XHPayParameterModel*)model;


/// 银联支付
/// @param model 参数 model.product_code = @"02030001"
-(void)unionPayWith:(XHPayParameterModel*)model;


/// 微信支付
/// @param model 参数 model.product_code = @"02010005"
-(void)weixinPayWith:(XHPayParameterModel*)model;


/// 支付宝支付
/// @param model 参数 model.product_code = @"02020004"
-(void)alipayPayWith:(XHPayParameterModel*)model;



@end

NS_ASSUME_NONNULL_END
