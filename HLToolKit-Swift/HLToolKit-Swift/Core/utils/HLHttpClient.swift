//
//  HLHttpClient.swift
//  Alamofire
//
//  Created by Liang on 2019/5/23.
//

import Alamofire

open class HttpResponse<T:Codable>:Codable {
    var data:T?
    var msg:String?
    var code:Int?
}


fileprivate let kHLNetworkClientErrorDomain = "com.httpclient.errordomain"


public enum HLHttpError : Error {
    case alamofireRequestFailed
}


class HLError {
    final class func initialize(errorCode:Int? , desc:String?) -> NSError {
        return NSError.init(domain: kHLNetworkClientErrorDomain, code: errorCode!, userInfo: [NSLocalizedDescriptionKey: desc!])
    }
}

public protocol DataProtectd {
    
    func encryptParams(_ params:AnyObject) -> AnyObject
    
    func decryptParams(_ params:AnyObject) -> AnyObject
}

open class HttpClient {
    private static var singleClient:HttpClient = {
        let client = HttpClient.init()
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
        
        return client
    }()
    
    private init() {
    }
    
    open class func defaultClient() -> HttpClient {
        return singleClient
    }
    //这里处理网络访问层的结果
    public final func request(_ url:URL, _ requestMethod:HTTPMethod, _ params:[String : Any]? = nil , _ completionHandler:@escaping (_ anyObj :Data? ,_ error :Error?) -> Void ) -> Void {
        if requestMethod != .get && requestMethod != .post {
            completionHandler(nil,HLError.initialize(errorCode: -1, desc: "This kind of Http method type is NOT supported"))
            return;
        }
        
        Alamofire.request(url, method: requestMethod, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                completionHandler(response.data!,nil)
            case .failure(let error):
                completionHandler(nil,error)
            }
        }
    }
}

protocol AnalyzeResponse {
//    @objc optional func analyzeResponse(_ xx:AnyObject) ->Void
}

open class HttpRequest {
    
    public class func requestData<T:Codable>(_ url:String,_ requestMethod:HTTPMethod,_ params:[String:Any]? = nil, _ structClass: T.Type, _ completionHandler:@escaping (_ anyObj:T?,_ error:Error?) -> Void) -> Void {
        HttpClient.defaultClient().request(URL.init(string: url)!, requestMethod, params) { (anyObj, error) in
            if error != nil {
                completionHandler(nil,HLError.initialize(errorCode: (error! as NSError).code , desc: (error! as NSError).localizedDescription))
                return
            }
            do {
                let responseModel = try JSONDecoder().decode(HttpResponse<T>.self, from: anyObj!)
                completionHandler(responseModel.data ,nil)
            } catch let error {
                completionHandler(nil,HLError.initialize(errorCode: (error as NSError).code , desc: "NO Response"))
            }
        }
    }
    
    public class func requestSuccess<T:Codable>(_ url:String,_ requestMethod:HTTPMethod,_ params:[String:Any]? = nil, _ structClass: T.Type, _ completionHandler:@escaping (_ success:Bool,_ error:Error?) -> Void) -> Void {
        HttpClient.defaultClient().request(URL.init(string: url)!, requestMethod, params) { (anyObj, error) in
            if error != nil {
                completionHandler(false,HLError.initialize(errorCode: (error! as NSError).code , desc: (error! as NSError).localizedDescription))
                return
            }
            do {
                let responseModel = try JSONDecoder().decode(HttpResponse<T>.self, from: anyObj!)
                if responseModel.code == 200 {
                    completionHandler(true ,nil)
                } else {
                    completionHandler(false,HLError.initialize(errorCode: responseModel.code!, desc: responseModel.msg!))
                }
            } catch let error {
                completionHandler(false,HLError.initialize(errorCode: (error as NSError).code , desc: "NO Response"))
            }
        }
    }

}
