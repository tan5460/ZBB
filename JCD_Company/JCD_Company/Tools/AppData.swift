/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

public struct AppData {
    
    /// 是否在审核
    public static var isExamine: NSNumber = 1
    /// 是否上线
    public static var isOnLine: NSNumber = 1
    /// 是否加载基础数据完成
    public static var isBaseDataLoaded: Bool = false
    /// 客服热线
//    public static var serviceTel: String = ""
    /// 软件简介
//    public static var yzbConfig: String = ""
    /// 好评链接
//    public static var yzbGoodLink: String = ""
    /// 服务器错误提示语
    public static var yzbWarning: String = "系统内部错误！"
    /// 积分兑换比例
    public static var yzbIntegral: String = ""
    
    
    /// 会员等级
    public static let gradeNameList = ["普通", "白银", "黄金", "钻石"]
    /// 验收状态. 0 待验收 1 已验收
//    public static var checkStatusList: [NSDictionary] = []
    /// 验收类型. 杂瓦 水电 泥工 木工
//    public static var checkTypeList: [NSDictionary] = []
    /// 报告类型 正常报告 异常报告
//    public static var reportTypeList: [NSDictionary] = []
    /// 客户工地状态 "接待客户","潜在客户","已交定金","待开工","施工中","已完工","失效客户"
//    public static var customStatusList: [NSDictionary] = []
    /// 工地房屋类型 平房 别墅 办公 店铺
//    public static var houseTypeList: [NSDictionary] = []
    /// 职位类型 客服 设计部管理 设计师 ...
//    public static var jobTypeList: [NSDictionary] = []
    /// 付款方式. 线上 线下
//    public static var payModeList: [NSDictionary] = []
    /// 借支状态 待项目经理审批 待工程经理审批 待总经理审批 待财务付款 财务已付款.
//    public static var payStatusList: [NSDictionary] = []
    /// 图片状态  未知  合格 不合格
//    public static var photoStatusList: [NSDictionary] = []
    /// 装修风格
    public static var styleTypeList: [NSDictionary] = []
    /// 性别 保密 男  女
    public static var sexList: [NSDictionary] = []
    /// 房间类型 主卧 卧室 次卧 儿童房 其他
    public static var roomTypeList: [NSDictionary] = []
    /// 自由下单房间类型
//    public static var orderRoomTypeList: [NSDictionary] = []
    /// 单位类型 平米 米 片 公斤 立方 个 套 条
    public static var unitTypeList: [NSDictionary] = []
    /// 主材规格
//    public static var materialSizeTypeList: [NSDictionary] = []
    /// 采购订单状态 生成订单 订单确认 完成付款 商家出货 确认收货 评价
    public static var purchaseOrderStatusTypeList: [NSDictionary] = []
    /// 订单状态 待付款 已付款 已完成
    public static var plusOrderStatusTypeList: [NSDictionary] = []
    /// 支付状态 未付款 支付失败 支付成功 支付审核中 支付成功（线下支付）
    public static var purchaseOrderPayStatusList: [NSDictionary] = []
    /// 施工分类 设计 监工 安装
//    public static var serviceTypeList: [NSDictionary] = []
    /// 施工分类 结构改造 泥工铺贴 天棚 墙面 木工 油漆 泥瓦工 防水工程 水电及安装 设计
    public static var serviceCategoryList: [NSDictionary] = []
    /// 施工类型 套餐 常规 加减价
//    public static var serviceTemplTypeList: [NSDictionary] = []
    /// 房子面积 60平方
    public static var houseAreaList: [NSDictionary] = []
    /// 房子户型 一室 二室
    public static var houseTypesList: [NSDictionary] = []
    /// 攻略类型
    public static var yzbStrategyList: [NSDictionary] = []
    /// 发货期限
    public static var yzbSendTermList: [NSDictionary] = []
    /// 服务类型
    public static var serviceTypes: [NSDictionary] = []
    /// 工人类型
    public static var workTypes: [NSDictionary] = []
    /// 服务字典
    public static var brandProtectionList: [NSDictionary] = []
    
    /// 服务订单状态
    public static var serviceStatusTypes: [NSDictionary] = [
        ["value" : "2", "label" : "等待服务商确认"],
        ["value" : "3", "label" : "服务商已确认"],
        ["value" : "4", "label" : "待服务商服务"],
        ["value" : "6", "label" : "服务已完成"],
        ["value" : "8", "label" : "订单取消"],
        ["value" : "11", "label" : "已失效"],
        ["value" : "12", "label" : "待验收"],
        ["value" : "13", "label" : "质保中"]
    ]
  
}
