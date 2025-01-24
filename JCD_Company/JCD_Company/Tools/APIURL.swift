

/* 每个APP对应的服务器接口 */

/*
     接口访问状态
     public static final String SUCCESS ="000"; //成功
     public static final String FAILED = "001"; //失败
     public static final String PARAMS_ERROR = "002"; //参数错误
     public static final String SERVER_ERROR = "003"; //服务器异常
     public static final String AUTHENTICATING_API_FAILED ="004";  //验证API请求失败
     public static final String API_NOT_FOUND = "005";  //请求的API不存在
     public static final String NAME_ERROR ="006";  //用户名错误
     public static final String PASSWORD_ERROR ="007";  //密码错误
     public static final String NO_RECORD = "008";  //没有记录
     public static final String COVER_RECORD = "009";   //记录重复
     public static final String KEY_OUTTIME = "010";    //服务器key过期,需自动登录
     public static final String KEY_ERROR = "011";  //key错误，需手动登录
     public static final String SIGN_ERROR = "012";  //sign错误
     public static final String CODE_OUTTIME = "013";  //验证码过期
     public static final String CODE_ERROR = "014";  //验证码错误
     public static final String RECORD_OVERTOP = "015";  //超出记录范围
     public static final String EQUIPMENT_ERROR = "016";  //验证码key错误
     public static final String SIGN_OUTTIME = "017";  //sign超时
     018    //会员过期
     019    //未开通会员
     020    //未开通会员
     022    //重复提现
 */

/*
 主材二维码   "http://192.168.1.22:8020/yzb_port/QRcode?materials=1451d395aba04f73a8e6a11d70e764bf"
 */

enum AppEnvironment: String {
    case online =  "FormalEnvironment"    //正式
    case pre    = "PreEnvironment"          //预生产
    case test   = "TestingEnvironment"      //测试
}

import UIKit
struct   APIURL {
    //MARK: -注册协议
    static let registerAgreement:String="http://formal.szgjcd.com/other/agreement.html"
    //MARK: - 入驻协议
    static let registerAgreement1:String="https://formal.jcdcbm.com/other/ruzhuAgreement.html"
    //MARK: - 隐私条款
    static let privacy_agreement:String="https://www.jcdcbm.com/other/Privacy/Privacy_agreement.html"
    //MARK: -积分规则
    static let VIPIntegralRule:String="http://formal.szgjcd.com/other/jcdVIPintegralrule.html"
    
    //环境类型
    static var environmentType: AppEnvironment {
        return AppEnvironment.init(rawValue: (Bundle.main.infoDictionary?["PrivateSetting"] as! [String: String])["EvType"] ?? "TestingEnvironment") ?? .test
    }
    //所有地址
    static let serverPre    = "https://gys-test.jcdcbm.com"
    //static let serverPre    = "http://192.168.1.60:9999"
    //    static let serverTest   = "https://gys-pretest.jcdcbm.com"
    static let serverTest   = "https://port-test.zhubaobaozbb.com"
    //static let serverTest   = "http://192.168.1.60:9999"
    static let serverOnline = "https://gys.jcdcbm.com"
    
    static let webPre    = "https://test.jcdcbm.com/"
    static let webTest   = "https://www-test.jcdcbm.com/"
    static let webOnline = "https://www.jcdcbm.com/"
    //MARK: -
    static let ossPicTest   = "https://zhubaobao.obs.cn-east-3.myhuaweicloud.com/"
    static let ossPicOnline = "https://zhubaobao.obs.cn-east-3.myhuaweicloud.com/"
    // 供应商
    static let gysPre    = "https://gys-test.jcdcbm.com"
    static let gysTest   = "https://gys-pretest.jcdcbm.com"
    static let gysOnline = "https://gys.jcdcbm.com"
    
    static let jzTest   = "https://jz-test.yzb.store"
    static let jzOnline = "https://jz.yzb.store"
    
    static let zfTest   = "https://zf-pretest.jcdcbm.com"
    static let zfPre   =  "https://zf-test.jcdcbm.com"
    static let zfOnline = "https://payment.jcdcbm.com"
    
    //使用地址 默认测试服
    static var serverPath = "/yzb_port"
    static var serverUrl = serverTest
    static var webUrl = webTest
    static var ossPicUrl = ossPicTest
    static var jzUrl = jzTest
    static var gysUrl = gysTest
    static var zfUrl = zfTest
    
    //MARK: - 聚材道新增地址
    //上传凭证的接口（新增）
    static var uploadOrderVoucher: String {
        get {
            return serverUrl+serverPath+"/uploadOrderVoucher"
        }
    }
    //上传凭证的接口（新增）
    static var uploadPayVoucher: String {
        get {
            return serverUrl+serverPath+"/uploadPayVoucher"
        }
    }
    
    //会员等级
    static var memberLevel: String {
        get {
            return serverUrl+serverPath+"/serviceRate/list"
        }
    }
    
    //会员信息
    static var memberInfo: String {
        get {
            return serverUrl+"/serviceRate/getPurLevelInfo"
        }
    }
    
    //首页背景形象图的接口（新增）
    static var backImgInfo: String {
        get {
            return serverUrl+"/jcdGys/materials/newBackImgInfo"
        }
    }
    
    //获取活动主材信息(首页) （新增）
    static var getMaterialsList: String {
        get {
            return serverUrl + "/jcdGys/materials/getList"
        }
    }
    
    //获取秒杀
    static var getSecondList: String {
        get {
            return serverUrl+serverPath+"/yzbMaterials/getSecondList"
        }
    }
    
    //商城品牌筛选接口（新增）：
    static var findListByCategory: String {
        get {
            return serverUrl+serverPath+"/yzbMerchant/findListByCategory"
        }
    }
    //会员商城获取二级分类
    static var secondCategoryList: String {
        get {
            return serverUrl+"/jcdGys/materials/pageMaterials"
        }
    }
    
    //会员商城获取二级分类
    static var secondCategoryBrandList: String {
        get {
            return serverUrl+"/jcdGys/merchantBrand/getByCategory/"
        }
    }
    
    //会员商城获取二级分类（新）
    static var newSecondCategoryBrandList: String {
        get {
            return serverUrl+"/jcdGys/merchantBrand/getByThreeCategory/"
        }
    }
    
    // MAKR - 余额支付获取验证码
    static var balancePayMsg: String {
        get {
            return serverUrl+"/jcdGys/comStore/balancePayMsg"
        }
    }
    
    //MARK: - 家装公司
    
    //MARK: -基础数据（返回文件数据）
    static var getBaseInfo: String {
        get {
            return serverUrl+"/jcdSys/config/getBaseInfo"
        }
    }
    //MARK: -获取工地列表
    static var getHouseList: String {
        get {
            return serverUrl+"/jcdGys/house/page"
        }
    }
    //MARK: -保存单个工地
    static var saveHouse: String {
        get {
            return serverUrl+"/jcdGys/comCustom/updateCusAndHouse"
        }
    }
    
    //MARK: -有客户信息，添加工地
    static var addHouseWithCustomId: String {
        get {
            return serverUrl+"/jcdGys/house/save"
        }
    }
    
    //MARK: -删除单个工地
    static var delHouse: String {
        get {
            return serverUrl+"/jcdGys/house/delete/"
        }
    }
    //MARK: -保存员工信息接口
    static var workerSave: String {
        get {
            return serverUrl+"/jcdGys/comCustom/update"
        }
    }
    
    //MARK: -新增修改员工信息
    static var addUpdateCustomInfo: String {
        get {
            return serverUrl+"/jcdGys/comWorker/save"
        }
    }
    
    //MARK: -上传照片
    static var imageUpload: String {
        get {
            return serverUrl+"/jcdSys/jcdDataUpload/fileUpload"
        }
    }
    //MARK: -获取短信验证码
    static var getSMS: String {
        get {
            return serverUrl+"/jcdGys/comStore/sendMsgCode/"
        }
    }
    //MARK: -核对验证码
    static var checkCode: String {
        get {
            return serverUrl+serverPath+"/gysLogin/checkCode"
        }
    }
    //MARK: -获取支付验证码
    static var getValidPay: String {
        get {
            return jzUrl+"/yzbPurchaseOrder/port/validPay"
        }
    }
    //MARK: -员工登陆接口
    static var login: String {
        get {
            return serverUrl+"/jcdSys/user/login"
        }
    }
    
    //MARK: -家装公司注册
    static var companyRegister: String {
        get {
            return serverUrl+"/jcdGys/register/save"
        }
    }
    
    
    //MARK: -服务商注册第一步
    static var serviceRegisterStepOne: String {
        get {
            return serverUrl+"/jcdGys/merchant/registerFirst"
        }
    }
    
    //MARK: -供应商注册第一步v2
    static var serviceRegisterStepOneV2: String {
        get {
            return serverUrl+"/jcdGys/merchant/v2/registerFirst"
        }
    }
    
    //MARK: -服务商注册第二步
    static var serviceRegisterStepTwo: String {
        get {
            return serverUrl+"/jcdGys/merchant/registerLast"
        }
    }
    
    //MARK: -会员v2注册
    static var regiestV2: String {
        get {
            return serverUrl+"/jcdGys/register/v2/save"
        }
    }
    
    //MARK: - ZBB注册
    static var zbbRegister: String {
        get {
            return serverUrl + "/jcd-gys/comStore/register"
        }
    }
    
    //MARK: -获取员工信息
    static var getUserInfo: String {
        get {
            return serverUrl+"/jcdSys/user/info"
        }
    }
    
    //MARK: -获取最新营销活动的icon
    static var activityIcon: String {
        get {
            return serverUrl+"/jcdGys/jcdMarketingActivities/activityIcon"
        }
    }
    
    //MARK: -获取指定员工信息
    static var getAppointUserInfo: String {
        get {
            return serverUrl+"/jcdGys/comWorker/get/"
        }
    }
    
    //MARK: -获取团队成员列表
    static var getComWorkers: String {
        get {
            return serverUrl+"/jcdGys/comWorker/page"
        }
    }
    
    //MARK: -修改员工密码
    static var updatePassword: String {
        get {
            return serverUrl+"/jcdSys/user/edit"
        }
    }
    
    
    //MARK: -忘记密码 重置密码
    static var resetPassword: String {
        get {
            return serverUrl+"/jcdSys/user/forgetPassword"
        }
    }
    
    //MARK: -2020.2.15 获取新分类接口，组合购买功能
    static var getNewCategory: String {
        get {
            return serverUrl+"/jcdGys/materialsCategory/appMaterialsCategory/getCategory"
        }
    }
    
    //MARK: -获取材料商列表  系统品牌(id)
    static var getMerchant: String {
        get {
            return serverUrl+"/jcdGys/merchantBrand/brandPavilion"
        }
    }
    //MARK: -获取材料商列表  系统品牌介绍html(传id)
    static var getMerchantIntoDetail: String {
        get {
            return serverUrl+"/jcdGys/merchantBrand/getMerchantIntoDetail/?id="
        }
    }
    
    //MARK: -获取app版本更新信息
    static var getVersion: String {
        get {
            return serverUrl+"/jcdSys/version/appVersion"
        }
    }
    //MARK: -获取所有主材
    static var getMaterials: String {
        get {
            return serverUrl+"/jcdGys/materials/pageMaterials"
        }
    }
    
    //MARK: -获取所有主材
    static var getMoreMaterials: String {
        get {
            return serverUrl+"/jcdGys/materials/getMoreMatreials"
        }
    }
    
    
    //MARK: -获取sku主材列表(sku+spu)
    static var getSKUMaterials: String {
        get {
            return serverUrl+"/jcdGys/jcdMaterialsSku/querySkuMaterialsPage"
        }
    }
    
    //MARK: -app查询主材以及sku详情
    static var getMaterialsDetailsById: String = serverUrl + "/jcdGys/materials/getMaterialsDetailsById"
    
    //MARK: -获取营销活动产品详情
    static var marketingMaterial: String = serverUrl + "/jcdGys/jcdMarketingMaterials/get/"
    
    //MARK: -获取单个主材
    static var getSingleMaterials: String {
        get {
            return serverUrl+serverPath+"/yzbMaterials/findMaterials"
        }
    }
    //MARK: -保存订单
    static var saveOrder: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/jcdCompanyOrder"
        }
    }
    //MARK: -获取订单
    static var getCompanyOrder: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/page"
        }
    }
    //MARK: -获取订单数量
    static var getOrderNumber: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/getUncofirmOrderCount"
        }
    }
    //MARK: -删除订单
    static var delCompanyOrder: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/delete/"
        }
    }
    //MARK: -获取订单清单
    static var getComOrderData: String {
        get {
            return serverUrl+"/jcdOrder/comOrderData/get/queryComOrderDetails/"
        }
    }
    //MARK: -修改订单状态
    static var updateOrderStatus: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/update"
        }
    }
    //MARK: -获取预购订单
    static var getTestOrder: String {
        get {
            return serverUrl+serverPath+"/yzbOrderPlusdata/getPlanOrder"
        }
    }
    //MARK: -导出订单
    static var exportOrder: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/export"
        }
    }
    //MARK: -获取公司客户列表
    static var getCompanyCustom: String {
        get {
            return serverUrl+"/jcdGys/comCustom/page"
        }
    }
    //MARK: -修改会员客户
    static var companyCustomSave: String {
        get {
            return serverUrl+"/jcdGys/comCustom/update"
        }
    }
    
    //MARK: -添加会员客户
    static var addCustom: String {
        get {
            return serverUrl+"/jcdGys/comCustom/save"
        }
    }
    
    
    //MARK: -装修公司客户和工地添加
    static var companyCusAndHouseSave: String {
        get {
            return serverUrl+"/jcdGys/comCustom/createCusAndHouse"
        }
    }
    //MARK: -删除装修公司客户
    static var customDel: String {
        get {
            return serverUrl+"/jcdGys/comCustom/deleteByIds"
        }
    }
    //MARK: -添加购物车
    static var saveCartList: String {
        get {
            return serverUrl+"/jcdGys/shoppingCart/save"
        }
    }
    //MARK: -查询是否已添加至购物车
    static var isExistCartList: String {
        get {
            return serverUrl+serverPath+"/yzbCartlist/isExist"
        }
    }
    //MARK: -获取购物车列表
    static var getCartList: String {
        get {
            return serverUrl+"/jcdGys/shoppingCart/get"
        }
    }
    //MARK: -批量删除购物车
    static var delBatchCartList: String {
        get {
            return serverUrl+"/jcdGys/shoppingCart/deletePartOfSku"
        }
    }
    //MARK: -获取施工商城
    static var getComService: String {
        get {
            return serverUrl+serverPath+"/yzbCompanyService/getComService"
        }
    }
    //MARK: -获取主材分类规格
    static var getSpecification: String {
        get {
            return serverUrl+serverPath+"/yzbMaterialsCategory/getYzbSpecificationDataList"
        }
    }
    //MARK: -新增自建主材
    static var addCompanyMaterial: String {
        get {
            return serverUrl+serverPath+"/yzbMaterialsCompanyAdd/psave"
        }
    }
    //MARK: -新增自建供应商
    static var addMerchant: String {
        get {
            return serverUrl+serverPath+"/yzbComMerchant/psave"
        }
    }
    //MARK: -交易记录
    static var getOrderCount: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/comOrderMonth"
        }
    }
    //MARK: -获取积分排名
    static var getRank: String {
        get {
            return serverUrl+serverPath+"/getRank"
        }
    }
    //MARK: -获取积分商城列表
    static var exchange: String {
        get {
            return serverUrl+serverPath+"/exchange"
        }
    }
    //MARK: -提现、兑换
    static var exchangeGoods: String {
        get {
            return serverUrl+serverPath+"/exchangeGoods"
        }
    }
    //MARK: -获取提现限制
    static var withdrawCount: String {
        get {
            return serverUrl+serverPath+"/withdrawCount"
        }
    }
    //MARK: -获取积分明细
    static var getChangeDetail: String {
        get {
            return serverUrl+serverPath+"/getChangeDetail"
        }
    }
    //MARK: -获取已开通城市列表
    static var findCityList: String {
        get {
            return serverUrl+"/jcdSys/citySubstation/findCityList"
        }
    }
    
    //MARK: - 获取全国省份
    static var getAllProvList: String {
        get {
            return serverUrl+"/jcdPub/sysArea/getProvList"
        }
    }
    
    //MARK: - 根据省份获取全部城市
    static var getAllCityList: String {
        get {
            return serverUrl+"/jcdPub/sysArea/getCityListByProvId/"
        }
    }
    
    //MARK: - 根据城市获取全部地区
    static var getAllDistList: String {
        get {
            return serverUrl+"/jcdPub/sysArea/getAreaByCityId/"
        }
    }
    
    //MARK: -获取省份
    static var getProvList: String {
        get {
            return serverUrl+"/jcdPub/sysArea/getProv"
        }
    }
    
    //MARK: -获取已开通分站的城市
    static var getCityListByProvId: String {
        get {
            return serverUrl+"/jcdPub/sysArea/getCityByProId/"
        }
    }
    
    //MARK: -获取城市分站
    static var getSubstationListByCityId: String {
        get {
            return serverUrl+"/jcdSys/citySubstation/getAreaSuspendByCityId/"
        }
    }
    
    
    
    //MARK: -获取已开通城市的运营商
    static var findOperatorList: String {
        get {
            return serverUrl+"/jcdSys/citySubstation/findCitySubsList"
        }
    }
    //MARK: -获取我的邀请数据
    static var getMyInvite: String {
        get {
            return serverUrl+serverPath+"/yzbWorker/findWorkerList"
        }
    }
    //MARK: -获取主材包对应差价(跟选)
    static var getPackageCusPrice: String {
        get {
            return serverUrl+serverPath+"/yzbOrderPlusdata/getCusPrice"
        }
    }
    
    //MARK: -获取全屋案例列表
    static var getHouseCase: String {
        get {
            return serverUrl+"/jcdGys/houseCase/getHouseCase"
        }
    }
    //MARK: -获取全屋案例详情
    static var getCaseDetail: String {
        get {
            return serverUrl+serverPath+"/yzbCase/getCaseDetail"
        }
    }
    //MARK: -获取全屋案例小区接口
    static var getCaseCommunityList: String {
        get {
            return serverUrl+"/jcdGys/house/communityList"
        }
    }
    //MARK: -根据街道ID查询小区列表
    static var getVillageList: String {
        get {
            return serverUrl+serverPath+"/village/list"
        }
    }
    //MARK: -套餐详情
    static var getPlusDetails: String {
        get {
            return serverUrl+serverPath+"/yzbPlus/getPlusDetails?id="
        }
    }
    
    //MARK: -vr设计
    static var findAllPlan: String {
        get {
            return serverUrl+"/jcdGys/vr/getPlanList"
        }
    }
    //MARK: -vr详情
    static var getPano: String {
        get {
            return serverUrl+"/jcdGys/vr/getRenderpicList"
        }
    }
    //MARK: -vr清单
    static var listingToOrder: String {
        get {
            return serverUrl+"/jcdGys/vr/outfitDetail"
        }
    }
    
    
    //MARK: -采购订单支付
    static var purchaseOrderPay: String {
        get {
            return jzUrl+"/yzbPurchaseOrder/port/pay"
        }
    }
    //MARK: -微信支付宝支付
    static var appPurchaseOrderPay: String {
        get {
            return jzUrl+"/yzbPurchaseOrder/port/appPurchaseOrderPay"
        }
    }
    //MARK: -会员费支付
    static var payAppVipSave: String {
        get {
            return jzUrl+"/yzbPurchaseOrder/port/payAppVipSave"
        }
    }
    //MARK: -查询会员费
    static var getVipMoney: String {
        get {
            return serverUrl+"/jcdGys/comStore/getActivityVipMoney"
        }
    }
    //MARK: - 获取vip和普通会员信息接口(参数：substationId)
    static var getMembershipInfo: String {
        get {
            return serverUrl + "/jcdGys/comStore/getActivityVipMoney"
        }
    }
    
    //MARK: - 获取vip和普通会员等级信息接口(7个等级)(参数：substationId)
    static var getMemberLevelList: String {
        get {
            return serverUrl + "/jcdGys/jcdMemberLevel/memberLevelList"
        }
    }
    
    //MARK: - 杉德 订单查询
    static var sandOrderQuery: String {
        get {
            return serverUrl + "/jcdPayment/sandOrderPc/orderQuery"
        }
    }
    
    //MARK: - 会员缴费接口
    
    //MARK: -轮播
    static var wheelList: String {
        get {
            return serverUrl+serverPath+"/yzbProgram/wheelList"
        }
    }
    //MARK: -轮播详情html(传id)
    static var wheelDetail: String {
        get {
            return serverUrl+serverPath+"/yzbProgram/wheelDetailJsp?id="
        }
    }
    //MARK: -轮播展厅介绍详情html(传id)
    static var wheelCityDetail: String {
        get {
            return serverUrl+serverPath+"/yzbProgram/cityDetailJsp?id="
        }
    }
    //MARK: -装修攻略
    static var raidersList: String {
        get {
            return serverUrl+serverPath+"/yzbProgram/raidersList"
        }
    }
    //MARK: -装修攻略详情html(传id)
    static var raidersDetail: String {
        get {
            return serverUrl+serverPath+"/yzbProgram/raidersDetailJsp?id="
        }
    }
    //MARK: -获取公司员工
    static var getWorkerList: String {
        get {
            return serverUrl+serverPath+"/yzbWorker/findList"
        }
    }
    
    //MARK: - 采购员
    //MARK: -采购员预购清单
    static var getPurchaseCartList: String {
        get {
            return serverUrl+"/jcdGys/shoppingCart/get"
        }
    }
    //MARK: -查询是否已加入预购清单
    static var isAddPurchase: String {
        get {
            return serverUrl+serverPath+"/jzYzbPurchaseOrder/isExist"
        }
    }
    //MARK: -采购员删除预购清单
    static var purchaseDelAllCart: String {
        get {
            return serverUrl+"/jcdGys/shoppingCart/deletePartOfSku"
        }
    }
    //MARK: -保存采购订单
    static var savePurchaseOrder: String {
        get {
            return serverUrl+"/jcdOrder/comOrder/purchaseOrder"
        }
    }
    
    
    //MARK: - 供应商
    
    //MARK: -供应商登陆接口
    static var gysLogin: String {
        get {
            return serverUrl+serverPath+"/gysLogin/checkIn"
        }
    }
    //MARK: -获取采购订单
    static var purchaseOrder: String {
        get {
            return gysUrl+"/gys/purchaseOrder/getList"
        }
    }
    //MARK: -采购订单详情
    static var getPurchaseOrderInfo: String {
        get {
            return gysUrl+"/purchaseOrder/purchaseOrderInfo"
        }
    }
    //MARK: -获取供应商信息
    static var getGYSUserInfo: String {
        get {
            return gysUrl+"/user/get"
        }
    }
    //MARK: -修改采购主材备注
    static var editGYSMater: String {
        get {
            return gysUrl+"/purchaseOrder/editMater"
        }
    }
    //MARK: -修改订单状态
    static var purchaseOrderStatus: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/update"
        }
    }
    
    //MARK: -供需市场 取消订单接口
    static var cancelPurchaseOrder: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/cancelPurchaseOrder"
        }
    }
    
    //MARK: -确认订单
    static var surePurchaseOrder: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/confirmOrder"
        }
    }
    
    //MARK: -修改服务费
    static var editServiceMoney: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/editOrderServiceMoney"
        }
    }
    //MARK: -修改补差价产品
    static var editSpreadProduct: String {
        get {
            return gysUrl+"/purchaseOrder/editSpreadProduct"
        }
    }
    //MARK: -添加补差价产品
    static var addSpreadProduct: String {
        get {
            return gysUrl+"/purchaseOrder/addSpreadProduct"
        }
    }
    //MARK: -删除采购商品
    static var deletePurchaseMar: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/deleteOrderData"
        }
    }
    //MARK: -删除补差价产品
    static var deleteProSpreadProduct: String {
        get {
            return gysUrl+"/purchaseOrder/deleteProSpreadProduct"
        }
    }
    //MARK: -采购订单添加产品
    static var addPurchaseMater: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/addSkuOrderOper"
        }
    }
    //MARK: -修改供应商
    static var editServiceTel: String {
        get {
            return serverUrl+"/jcdGys/merchant/update"
        }
    }
    //MARK: -修改供应商手机号码
    static var editGysMobile: String {
        get {
            return serverUrl+"/jcdGys/merchant/editMerchantMobile"
        }
    }
    //MARK: -获取开户信息
    static var getHfUserInfo: String {
        get {
            return gysUrl+"/user/getHfUserInfo"
        }
    }
    //MARK: -获取可提现余额
    static var getUserBalance: String {
        get {
            return gysUrl+"/user/getUserBalance"
        }
    }
    //MARK: -获取银行卡列表
    static var getBankList: String {
        get {
            return gysUrl+"/bank/getList"
        }
    }
    //MARK: -是否可提现
    static var withdrawCheck: String {
        get {
            return gysUrl+"/payment/withdrawCheck"
        }
    }
    
    //MARK: -下单
    static var orderPay: String {
        get {
            return serverUrl+"/jcdPayment/order/appOrderPay"
        }
    }
    
    static var vipPay: String {
        get {
            return serverUrl+"/jcdPayment/wallet/appPayVip"
        }
    }
    
    //MARK: -开户 - 余额
    static var lessMoney: String {
        get {
            return serverUrl+"/jcdGys/wallet/queryPingUser"
        }
    }
    
    //MARK: - 衫德支付 -APP支付 支付会员费
    static var sandPayVip: String {
        get {
            return serverUrl+"/jcdPayment/sandOrder/appPayVip"
        }
    }
    
    //MARK: - 衫德支付 -APP支付 支付会员费
    static var sandPayOrder: String {
        get {
            return serverUrl+"/jcdPayment/sandOrder/appCreateOrder"
        }
    }
    
    //更新支付状态
    static var updatePurchaseStatus: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/update"
        }
    }
    
    //MARK: -提现
    static var withdrawMoney: String {
        get {
            return serverUrl+"/jcdPayment/wallet/appWithdraw"
        }
    }
    //MARK: -提现记录
    static var getWithdrawList: String {
        get {
            return serverUrl+"/jcdOrder/paymentOrder/appWithdrawRecords"
        }
    }
    //MARK: -免费开通会员
    static var openForFree: String {
        get {
            return serverUrl+"/jcdGys/yzbVip/openForFree"
        }
    }
    //MARK: - 会员缴费接口（加两个参数：payVipType ： vip--聚材道vip会员  general--聚材道普通会员 payMoney：支付金额）
    static var membershipPay: String {
        get {
            return serverUrl+"/jcdPayment/wallet/appPayVip"
        }
    }
    
    
    //MARK: -退出登录
    static var logout: String {
        get {
            return serverUrl+"/jcdSys/user/logout"
        }
    }
    //MARK: -修改头像
    static var updateHeadUrl: String {
        get {
            return serverUrl+serverPath+"/city/updateHeadUrl"
        }
    }
    //MARK: -公司资质
    static var getMerchantInfo: String {
        get {
            return serverUrl+"/jcdGys/merchant/getCertpicUrl/"
        }
    }
    
    
    //MARK: - 运营商
    
    //MARK: -运营商登录
    static var yysLogin: String {
        get {
            return serverUrl+serverPath+"/city/login"
        }
    }
    //MARK: -获取运营商信息
    static var getYYSUserInfo: String {
        get {
            return serverUrl+serverPath+"/city/getInfo"
        }
    }
    //MARK: -获取采购列表
    static var getYYSPurchaseOrder: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/page"
        }
    }
    //MARK: -获取采购清单
    static var getYYSPurchaseOrderData: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/queryPurchaseOrderDetail/"
        }
    }
    //MARK: - 获取采购清单佣金费率
    static var getYYSpurchaseOrderRate: String {
        get {
            return serverUrl+serverPath+"/yzbPurchaseOrderData/getPlatformMoney"
        }
    }
    
    //MARK: -获取家装公司消息
    static var pageStoreMessage: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/pageStoreMessage"
        }
    }
    
    //MARK: -采购员获取待办
    static var getMessageList: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/pageSysMessage"
        }
    }
    //MARK: -供应商获取待办
    static var pageMerchantMessage: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/msgPage"
        }
    }
    //MARK: -删除待办
    static var deleteSysMessage: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/deleteSysMessage"
        }
    }
    //MARK: -删除采购订单
    static var delPurchaseOrder: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/delete/"
        }
    }
    //MARK: -待办消息处理
    static var messageIsDeal: String {
        get {
            return serverUrl+serverPath+"/message/isDeal"
        }
    }
    
    //MARK: -待办消息修改
    static var updateMessage: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/update"
        }
    }
    
    
    //MARK: -修改手机号
    static var modifyYYSMobile: String {
        get {
            return serverUrl+serverPath+"/city/saveMobile"
        }
    }
    //MARK: -获取系统通知列表
    static var getMsgPushList: String {
        get {
            return serverUrl+"/jcdOrder/sysMessage/pageStoreMessage"
        }
    }
    //MARK: -获取启动页
    static var getAppStartPage: String {
        get {
            return serverUrl+"/jcdSys/version/getAppStartPage"
        }
    }
    //MARK: - 获取总后台下载资料
    static var getDownloadData: String {
        get {
            return serverUrl+"/jcdSys/jcdDataUpload/list"
        }
    }
    
    //MARK: - 获取角色列表
    static var getRoleList: String {
        get {
            return serverUrl+"/jcdGys/merchant/merchantServiceList"
        }
    }
    
    //MARK: - 获取装饰公司列表
    static var getZSCompanyList: String {
        get {
            return serverUrl+"/jcdGys/comStore/findListByTypeAndSubstation"
        }
    }
    
    
    //MARK: - 更改订单金额价格
    static var editServiceOrderMoney: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/update"
        }
    }
    
    
    //MARK: - 修改清单产品数据
    static var editOrderSku: String {
        get {
            return serverUrl+"/jcdOrder/purchaseOrder/editOrderSku"
        }
    }
    
    
    
    // MARK: - 服务商城接口
    //MARK: - 服务商城-精选服务接口 get
    static var getServiceMerchantPage = serverUrl+"/jcdGys/merchant/getServiceMerchantPage"
    //MARK: - 工人资源-工长团队、案例数据接口 get
    static var getForemanTeamAndCase = serverUrl+"/jcdGys/merchant/getForemanTeamAndCase"
    //MARK: - 工人资源-工人列表数据接口 get
    static var getServiceWorkerPage = serverUrl+"/jcdGys/merchant/getServiceWorkerPage"
    //MARK: - 获取更多工长团队接口 get
    static var getMoreForemanTeam = serverUrl+"/jcdGys/merchant/getMoreForemanTeam"
    //MARK: - 工长团队详情接口 get
    static var getForemanTeamDetails = serverUrl+"/jcdGys/merchant/getForemanTeamDetails"
    //MARK: - 获取案例列表数据接口(工长案例、设计案例) get
    static var findHouseCasePage = serverUrl+"/jcdGys/houseCase/findPage"
    //MARK: - 获取已开通城市分站省份数据接口 get
    static var getProvs = serverUrl+"/jcdPub/sysArea/getProv"
    //MARK: - 获取个人详情接口 get
    static var getPersonalDetails = serverUrl+"/jcdGys/merchant/getPersonalDetails"
    //MARK: - 获取设计资源接口 get
    static var getDesignResources = serverUrl+"/jcdGys/merchant/getDesignResources"
    //MARK: - 获取设计资源列表数据接口 get
    static var getDesignResourcesList = serverUrl+"/jcdGys/merchant/getDesignResourcesList"
    //MARK: - 获取服务商城相关banner图  get
    static var getBannerByType = serverUrl+"/jcdGys/merchant/getBannerByType"
    //MARK: - 获取已开通分站的城市数据  get
    static var getSubstationCity = serverUrl+"/jcdPub/sysArea/getSubstationCity"
    //MARK: - 获取单个节点详情  get
    static var getNodeData = serverUrl+"/jcdOrder/jcdServiceOrderNodeData/get/{id}"
    //MARK: - 上传节点图片(修改节点状态)  put
    static var updateNodeData = serverUrl+"/jcdOrder/jcdServiceOrderNodeData/update"
    //MARK: - 节点验收  post
    static var checkNode = serverUrl+"/jcdOrder/jcdServiceOrderNodeData/nodeAcceptance/"
    //MARK: - 发起质保  post
    static var doWarranty = serverUrl+"/jcdOrder/purchaseOrder/doWarranty/"
    //MARK: - 下架  put
    static var updUpperFlag = serverUrl+"/jcdGys/materials/updUpperFlag"
    //MARK: - 修改咨询人数（人气）接口  post
    static var updConsultNum = serverUrl+"/jcdGys/merchant/updConsultNum"
    
    //MARK: - 查询供需首页接口 Get
    static var getGXHomeData = serverUrl+"/jcdGys/jcdWorkbench/gxIndex"
    
    //MARK: - 查询清仓产品品牌以及分类 Get
    static var getClearanceBrandAndCategory = serverUrl+"/jcdGys/clearanceActivities/getClearanceBrandAndCategory"
    
    //MARK: - 分页查询清仓活动 GET
    static var getClearancActivities = serverUrl+"/jcdGys/clearanceActivities/page"
    
    //MARK: - 获取特惠活动产品一级分类数据(看需求使用)  GET
    static var getTHCategory = serverUrl+"/jcdGys/jcdPromotionalMaterials/getCategory"
    
    //MARK: - 获取特惠活动产品品牌数据 GET
    static var getTHBrand = serverUrl+"/jcdGys/jcdPromotionalMaterials/getBrand"
    
    //MARK: - 获取团购邀请产品的所有品牌 GET
    static var getGroupBrand = serverUrl+"/jcdGys/groupPurchaseInvites/getBrands"
    
    //MARK: - 分页查询清仓活动 GET
    static var getPromotionalMaterials = serverUrl+"/jcdGys/jcdPromotionalMaterials/getMaterials"
    
    //MARK: - 查询我的发布  GET
    static var myPublishMaterials = serverUrl+"/jcdGys/clearanceActivities/myPublishMaterials"
    
    //MARK: - 删除特惠产品接口 DELETE
    static var delMaterials = serverUrl+"/jcdGys/jcdPromotionalMaterials/delMaterials"
    
    //MARK: - 删除新品现货产品 DELETE
    static var deleteNewProductsMaterials = serverUrl+"/jcdGys/newProductsMaterials/delete/"
    
    //MARK: - 获取公司详情
    static var getCompanyDetail = serverUrl+"/jcdGys/comStore/appStoreDetailIndex"
    
    //MARK: - 获取企业证书列表
    static var getCertificateList = serverUrl+"/jcdGys/jcdStoreFileData/getCertificateList"
    
    //MARK: - 会员代金券列表接口  get
    static var getCouponList = serverUrl+"/jcdGys/jcdStoreCashCoupon/page"
    
    
    
    //MARK: - 查询可用代金券列表(订单支付时) get
    static var getUsableCouponList = serverUrl+"/jcdGys/jcdStoreCashCoupon/getUsableCouponList"
    
    //MARK: - 查询可用优惠券列表(订单支付时) get
    static var getUsableDisCountCouponList = serverUrl+"/jcdGys/jcdStoreCashCoupon/getUsableDisCountCouponList"
    
    //MARK: - 查询推荐代金券列表(订单支付时) get
    static var getUsableCouponPlan = serverUrl+"/jcdGys/jcdStoreCashCoupon/getUsableCouponPlan"
    
    //MARK: - 一键选购
    static var restoreShoppingCart = serverUrl+"/jcdGys/shoppingCart/restoreShoppingCart"
    
    //MARK: - 确认发货
    static var confirmShipment = serverUrl+"/jcdOrder/purchaseOrder/confirmShipment"
    
    //MARK: - 修改物流信息
    static var editLogisticsInfo = serverUrl+"/jcdOrder/purchaseOrder/editLogisticsInfo"
    
    //MARK: - 帮助中心
    static var helpCenter = serverUrl+"/jcdSys/jcdHelpNotice/helpPage"
    
    //MARK: - 系统通知
    static var systremMessages = serverUrl+"/jcdOrder/sysMessage/pageStoreMessage"
    
    //MARK: - 系统通知（通知）
    static var appNoticePage = serverUrl+"/jcdSys/jcdHelpNotice/appNoticePage"
    
    //MARK: - 获取延长收货相关信息
    static var getDelayTimeInfo = serverUrl+"/jcdSys//jcdCostCoefficientSetting/getInfo"
    
    //MARK: - 延长收货
    static var delayReceivedGoods = serverUrl+"/jcdOrder/purchaseOrder/extendOrderAcceptTime"
    
    //MARK: - 根据手机号查询注册状态 get
    static var checkMobile = serverUrl+"/jcdGys/register/checkMobile"
    
    //MARK: - 检查手机号码是否注册 get
    static var checkMobileV2 = serverUrl+"/jcdGys/register/v2/checkMobile"
    
    //MARK: - 校验验证码 get
    static var checkValidateCode = serverUrl+"/jcdSys/user/checkValidateCode"
    
    //MARK: - 根据openId查询是否绑定了用户 get 返回的code 如果是1就是表示这个openId没有绑定用户
    static var checkOpenId = serverUrl+"/jcdSys/user/checkOpenId"
    
    //MARK: - 分页查询新品现货活动主材
    static var newProductsMaterials = serverUrl+"/jcdGys/newProductsMaterials/page"
    
    //MARK: - 发布团购邀请
    static var groupPurchaseInvites = serverUrl+"/jcdGys/groupPurchaseInvites/save"
    
    //MARK: - 分页获取团购邀请列表
    static var groupPurchaseInvitePage = serverUrl+"/jcdGys/groupPurchaseInvites/page"
    
    //MARK: - 分页获取团购报名列表
    static var groupPurchaseSignUp = serverUrl+"/jcdGys/groupPurchaseSignUp/page"
    
    //MARK: - 获取产品筛选类型
    static var jcdAttrClassification = serverUrl+"/jcdGys/jcdAttrClassification/getByCategory/"
    
    //MARK: - 获取产品筛选类型
    static var msgCount = serverUrl+"/jcdOrder/sysMessage/msgCount"
    
    //MARK: - 申请资料补充
    static var addInfo = serverUrl+"/jcdGys/jcdSandAcctInfo/addInfo"
    
    //MARK: - 分页获取营销活动
    static var jcdMarketingActivities = serverUrl+"/jcdGys/jcdMarketingActivities/page"
    
    //MARK: - app分页获取营销活动产品列表
    static var jcdMarketingMaterials = serverUrl+"/jcdGys/jcdMarketingMaterials/marketMaterialsPage"
    
    
    //MARK: - 区域产品
    //MARK: - 区域品牌 分页查询
    static var regionMerchantBrandPage = serverUrl+"/jcdGys/merchantBrand/regionMerchantBrandPage"
    
    //MARK: - 区域品牌详情页
    static var getRegionBrand = serverUrl+"/jcdGys/merchantBrand/getRegionBrand"
    
    //MARK: - 区域品牌产品页
    static var regionBrandProductPage = serverUrl+"/jcdGys/merchantBrand/regionBrandProductPage"
    
    //MARK: - 区域品牌 查询(搜索框)
    static var queryBrandOrProduct = serverUrl+"/jcdGys/merchantBrand/queryBrandOrProduct"
    
    
    //MARK: - 会员补充认证资料
    static var authFile = serverUrl+"/jcdGys/register/v2/save"
    
    //MARK: - 会员切换供应商
    static var switchMerchant = serverUrl+"/jcdSys/user/switchMerchant"
    
    //MARK: - 会员绑定供应商
    static var bindMerchant = serverUrl+"/jcdGys/comStore/bindMerchant"
    
    //MARK: - 我的钱包信息
    static var moneyBagInfo = serverUrl+"/jcdSys/sysAccount/getById/"
    
    //MARK: - 绑定微信或者支付宝账户
    static var jcdUserAppBind = serverUrl+"/jcdSys/jcdUserAppBind/save"
    
    //MARK: - 获取提现绑定账户列表
    static var jcdUserAppBindList = serverUrl+"/jcdSys/jcdUserAppBind/getList"
    
    //MARK: - 提现接口
    static var jcdWithdraw = serverUrl+"/jcdPayment/jcdWithdraw/withdraw"
    
    //MARK: - 提现记录分页列表
    static var jcdWithdrawRecord = serverUrl+"/jcdSys/jcdWithdrawRecord/withdrawPage"
    
    //MARK: - 收益明细分页列表
    static var jcdUserIncome = serverUrl+"/jcdSys/jcdUserIncome/incomePage"
    
    
    
    //MARK: - 授权支付宝
    static var authZFB = serverUrl+"/jcdPayment/payment/alipay/aliSign"
    
    
    
    //MARK: - 绑定支付宝
    static var authBindZFB = serverUrl+"/jcdPayment/payment/alipay/authBind"
    
    //MARK: - 获取广告图列表
    static var advertList = serverUrl+"/jcdSys/jcdAdvertColumn/advertList"
    
    
    
    
    //MARK: - 资信认证状态
    static var zbbAuthInfo = serverUrl + "/jcd-gys/comStore/authInfo"
    
    //MARK: - 已认证品牌
    static var zbbAuthBrands = serverUrl + "/jcd-gys/merchantBrand/auth/list"
    //MARK: - 提交品牌认证资料
    static var zbbApplyBrand = serverUrl + "/jcd-gys/brandMerchantAuth/save"
    //MARK: - 查询品牌认证资料
    static var zbbApplyBrandInfo = serverUrl + "/jcd-gys/brandMerchantAuth/getInfo"
    //MARK: - 编辑品牌认证资料
    static var zbbApplyBrandEdit = serverUrl + "/jcd-gys/brandMerchantAuth/edit"
    
    //MARK: - 已认证服务商
    static var zbbAuthServices = serverUrl + "/jcd-gys/zzbServiceMerchant/list"
    //MARK: - 查询服务商认证详情
    static var zbbServiceAuthInfo = serverUrl + "/jcd-gys/zzbServiceMerchant/getInfo/"
    //MARK: - 提交服务商认证资料
    static var zbbServiceAuthApply = serverUrl + "/jcd-gys/zzbServiceMerchant/apply"
    //MARK: - 编辑服务商认证资料
    static var zbbServiceAuthEdit = serverUrl + "/jcd-gys/zzbServiceMerchant/modifyInfo"
    
    //MARK: - 查询消费者认证详情
    static var zbbCustomerAuthInfo = serverUrl + "/jcd-sys/zbbConsumerAuth/getInfo/"
    //MARK: - 提交消费者认证资料
    static var zbbCustomerAuthApply = serverUrl + "/jcd-sys/zbbConsumerAuth/apply"
    //MARK: - 编辑消费者认证资料
    static var zbbCustomerAuthEdit = serverUrl + "/jcd-sys/zbbConsumerAuth/modifyInfo"
    
    //MARK: - 查询设计图列表
    static var zbbDesignDrawList = serverUrl + "/jcd-sys/zzbDesignDraw/list"
    //MARK: - 查询设计图详情
    static var zbbDesignDrawInfo = serverUrl + "/jcd-sys/zzbDesignDraw/getInfo/"
    //MARK: - 提交设计图认证
    static var zbbDesignDrawApply = serverUrl + "/jcd-sys/zzbDesignDraw/apply"
    //MARK: - 编辑设计图资料
    static var zbbDesignDrawEdit = serverUrl + "/jcd-sys/zzbDesignDraw/modifyInfo"
    
    
    //MARK: - 平台托管订单状态数量
    static var zbbOrderStatusCount = serverUrl + "/jcd-order/zbbTgOrder/appOrderStatusCount"
    //MARK: - 平台托管订单列表
    static var zbbOrderList = serverUrl + "/jcd-order/zbbTgOrder/page"
    //MARK: - 平台托管订单详情
    static var zbbOrderInfo = serverUrl + "/jcd-order/zbbTgOrder/getInfo/"
    
    //MARK: - 平台托管订单确认托管
    static var zbbOrderConfirm = serverUrl + "/jcd-order/zbbTgOrder/confirmOrder/"
    //MARK: - 平台托管订单申请结束
    static var zbbOrderApplyTerminate = serverUrl + "/jcd-order/zbbTgOrder/applyTerminate"
    //MARK: - 平台托管订单节点验收
    static var zbbOrderAcceptance = serverUrl + "/jcd-order/zbbTgOrder/acceptance"
    
    //MARK: - 平台托管订单支付记录
    static var zbbOrderPayRecord = serverUrl + "/jcd-order/zbbTgOrder/payRecord"
    //MARK: - 平台托管订单动态
    static var zbbOrderLog = serverUrl + "/jcd-order/zbbTgOrder/orderLog"
    //MARK: - 平台托管订单款项变更
    static var zbbOrderWaitPayNode = serverUrl + "/jcd-order/zbbTgOrder/getWaitPayNode"
    
    
    //MARK: - 装修维权列表
    static var zbbDecorationList = serverUrl + "/jcd-sys/zbbDecorationRightsProtection/appList"
    //MARK: - 装修维权投诉
    static var zbbDecorationApply = serverUrl + "/jcd-sys/zbbDecorationRightsProtection/add"
    
    
    //MARK: - 装修补贴
    static var zbbSubsidyOrderList = serverUrl + "/jcd-order/subsidyOrder/app/page"
    //MARK: - 补贴政策
    static var zbbSubsidyPolicy = serverUrl + "/jcdSys/dict/type/subsidy_policy"
    //MARK: - 装修补贴申领详情
    static var zbbSubsidyOrderInfo = serverUrl + "/jcd-order/subsidyOrder/getInfo"
    //MARK: - 装修补贴申领补贴
    static var zbbSubsidyOrderApply = serverUrl + "/jcd-order/subsidyOrder/completion"
    
    
    //MARK: -
    static var zbbOrderSubsidyInfo = serverUrl + "/jcd-order/purchaseOrder/subsidy"
    
    //MARK: -  已补贴金额
    static var zbbSubsidedAmount = serverUrl + "/jcd-order/purchaseOrder/subsided"
}
