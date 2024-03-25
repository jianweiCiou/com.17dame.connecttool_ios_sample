//
//  ViewController.swift
//  ConnectToo_Test
//
//  Created by Jianwei Ciou on 2024/3/25.
//

import UIKit
import ConnectTool

class ViewController: UIViewController {
    
    private var _connectTool: ConnectToolBlack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 工具初始
        let RSAstr = "";
        
        let X_Developer_Id = Bundle.main.infoDictionary?["X_Developer_Id"]
        let client_secret = Bundle.main.infoDictionary?["client_secret"]
        let redirect_uri = Bundle.main.infoDictionary?["redirect_uri"]
        let Game_id = Bundle.main.infoDictionary?["Game_id"]
        
        self._connectTool = ConnectToolBlack(_redirect_uri : redirect_uri as! String,
                                             _RSAstr : RSAstr,
                                             _client_id : X_Developer_Id as! String,
                                             _X_Developer_Id : X_Developer_Id as! String,
                                             _client_secret : client_secret as! String,
                                             _Game_id : Game_id as! String,
                                             _platformVersion: ConnectToolBlack.PLATFORM_VERSION.nativeVS );
        
        // 設定測試與正式
        self._connectTool?.setToolVersion(_toolVersion: ConnectToolBlack.TOOL_VERSION.testVS);
        //self._connectTool?.setToolVersion(_toolVersion:ConnectToolBlack.TOOL_VERSION.releaseVS);
        
        // 註冊 17dame 應用事件
        NotificationCenter.default.addObserver(self, selector: #selector(r17dame_ReceiverCallback),name: NSNotification.Name .r17dame_ReceiverCallback, object: nil)
    }
    
    
    // 移除 17dame 應用事件的訂閱
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.r17dame_ReceiverCallback, object: nil)
    }
    
    /// 17dame 應用事件回應
    @objc func r17dame_ReceiverCallback(_ notification: Notification){
        let backType = notification.userInfo?["accountBackType"]  as! String;
        
        // Complete purchase of SP Coin
        if (backType  ==  "CompletePurchase") {
            let TradeNo = notification.userInfo?["TradeNo"]  as! String;
            let PurchaseOrderId = notification.userInfo?["PurchaseOrderId"]  as! String;
            
            print("完成儲值 ")
            print("TradeNo : " +  TradeNo)
            print("PurchaseOrderId : " +  PurchaseOrderId)
        }
        
        // Complete consumption of SP Coin
        if (backType  ==  "CompleteConsumeSP") {
            let consume_status = notification.userInfo?["consume_status"]  as! String;
            let transactionId = notification.userInfo?["transactionId"]  as! String;
            let orderNo = notification.userInfo?["orderNo"]  as! String;
            let productName = notification.userInfo?["productName"]  as! String;
            let spCoin = notification.userInfo?["spCoin"]  as! Int;
            let rebate = notification.userInfo?["rebate"]  as! Int;
            let orderStatus = notification.userInfo?["orderStatus"]  as! String;
            let state = notification.userInfo?["state"]  as! String;
            let notifyUrl = notification.userInfo?["notifyUrl"]  as! String;
            
            print("完成消費 ")
            print("consume_status : " +  consume_status)
            print("transactionId : " +  transactionId)
            print("orderNo : " +  orderNo)
            print("productName : " +  productName)
            print("spCoin : \(spCoin)"   )
            print("rebate : \(rebate)"   )
            print("orderStatus : " +  orderStatus)
            print("state : " +  state)
            print("notifyUrl : " +  notifyUrl)
        }
        
        // get Access token
        if(backType == "Authorize"){
            let GetMe_RequestNumber = UUID();
            let state = "App-side-State";
            _connectTool?.appLinkDataCallBack_OpenAuthorize(
                notification:notification,
                _state:state,
                GetMe_RequestNumber:GetMe_RequestNumber
            ){
                /*
                 * App-side add functions.
                 */
                auth in
                print("Authorize 回應")
                print("userId : " + auth.meInfo.data.userId)
                print("email : " + auth.meInfo.data.email)
                print("spCoin : \(auth.meInfo.data.spCoin)")
                print("rebate : \(auth.meInfo.data.rebate)")
            }
        }
    }
    // 登入 / 註冊
    @IBAction func OpenAuthorizeURL(_: Any) {
        let state:String = "App-side-State";
        self._connectTool?.OpenAuthorizeURL(_state: state,rootVC: self)
    }
    
    // 取用戶登入資料
    @IBAction func GetMe_Coroutine(_: Any) {
        let GetMe_RequestNumber = UUID(); // App-side-RequestNumber(UUID), default random
        _connectTool?.GetMe_Coroutine(_GetMeRequestNumber: GetMe_RequestNumber, callback: { MeInfo in
            print("取用戶登入資料")
            print("userId : " + MeInfo.data.userId)
            print("email : " + MeInfo.data.email)
            print("nickName : " + (MeInfo.data.nickName ?? ""))
            print("spCoin : \(MeInfo.data.spCoin)")
            print("rebate : \(MeInfo.data.rebate)")
            print("avatarUrl : " + (MeInfo.data.avatarUrl ?? ""))
        })
    }
    
    
    // 切換帳號
    @IBAction func OpenSwitchAccountURL(_: Any) {
        self._connectTool?.SwitchAccountURL(rootVC: self)
    }
    
    /// 開啟儲值頁
    /// [here](https://github.com/jianweiCiou/com.17dame.connecttool_android/blob/main/README.md#open-recharge-page))
    @IBAction func OpenRechargeURL(_: Any) {
        let notifyUrl = "";// NotifyUrl is a URL customized by the game developer
        let state = "Custom state";// Custom state
        
        _connectTool?.set_purchase_notifyData(notifyUrl:notifyUrl,state:state);
        
        // Step2. Set currencyCode
        let currencyCode = "2";
        
        // Step3. Open Recharge Page
        _connectTool?.OpenRechargeURL(currencyCode:currencyCode,_notifyUrl: notifyUrl,state: state,rootVC: self);
    }
    
    
    @IBAction func OpenConsumeSPURL(_: Any) {
        let notifyUrl = "";// NotifyUrl is a URL customized by the game developer
        let state = UUID().uuidString; // Custom state , default random_connectTool.set_purchase_notifyData(notifyUrl, state);
        
        _connectTool?.set_purchase_notifyData(notifyUrl:notifyUrl,state:state);
        
        let  consume_spCoin = 10;
        let orderNo = UUID().uuidString; // orderNo is customized by the game developer
        let requestNumber = UUID().uuidString; // requestNumber is customized by the game developer, default random
        let GameName = "GameName";
        let productName = "productName";
        _connectTool?.OpenConsumeSPURL(consume_spCoin: consume_spCoin, orderNo: orderNo, GameName: GameName, productName: productName, _notifyUrl: notifyUrl, state: state, requestNumber: requestNumber,rootVC: self);
    }


}

extension Notification.Name {
    static var r17dame_ReceiverCallback: Notification.Name {
        return .init(rawValue: "com.r17dame.CONNECT_ACTION.ReceiverCallback") }
}
