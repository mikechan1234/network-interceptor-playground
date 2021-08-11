import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class NetworkInterceptor: URLProtocol {
    
    class func setup() {
        
        let registered = URLProtocol.registerClass(NetworkInterceptor.self)
        print("URLProtocol is registered: \(registered)")
        assert(registered, "URLProtocol should be registered")
        
        URLSessionConfiguration.default.protocolClasses?.append(NetworkInterceptor.self)
        
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        
        guard let url = task.currentRequest?.url else {
            return false
        }
        
        return StubGroup.canStub(url)
        
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        request
        
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        
        false
        
    }
    
    override func startLoading() {
        
        print("Start Loading")
        
        guard let client = client else {
            return
        }
        
        let (status, data, error) = StubGroup.stub(from: request)
        
        if let error = error {
            client.urlProtocol(self, didFailWithError: error)
            return
            
        }
        
        if let httpResponse = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "1.1", headerFields: nil) {
            
            client.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            
        }
        
        if let data = data {
            
            client.urlProtocol(self, didLoad: data)
            
        }
        
        client.urlProtocolDidFinishLoading(self)
        
    }
    
    override func stopLoading() {
        
        print("Stop Loading")
        
    }
    
}

protocol StubContent {
    
    var path: String {get}
    var status: Int {get}
    var data: Data? {get}
    var error: Error? {get}
    
}

extension NetworkInterceptor {
    
    enum Stub: StubContent, CaseIterable {
        
        case korea
        case uk
        
        var data: Data? {
            
            switch self {
            case .korea:
                
                guard let url = Bundle.main.url(forResource: "itunes-kr", withExtension: "json"), let data = try? Data(contentsOf: url) else {
                    return nil
                }
                
                return data

            case .uk:
                
                guard let url = Bundle.main.url(forResource: "itunes-uk", withExtension: "json"), let data = try? Data(contentsOf: url) else {
                    return nil
                }
                
                return data
            
            }
            
        }
        
        var path: String {
            
            switch self {
            case .korea:
                return "api/v1/kr/apple-music"
            case .uk:
                return "api/v1/gb/apple-music"
            }
            
        }
        
        var status: Int {
            
            switch self {
            case .korea:
                return 200
            case .uk:
                return 200
            }
            
        }
        
        var error: Error? {
            
            switch self {
            case .korea:
                return nil
            case .uk:
                return nil
            }
            
        }
        
    }
    
}

extension NetworkInterceptor {
    
    class StubGroup {
        
        private static let items = Stub.allCases
        
        class func canStub(_ url: URL) -> Bool {
            
            return items.contains { stubItem in
                
                url.path.contains(stubItem.path)
                
            }
            
        }
        
        class func stub(from urlRequest: URLRequest) -> (code: Int, data: Data?, error: Error?) {
            
            guard let item = items.first (where: { stubItem in
                
                return urlRequest.url?.path.contains(stubItem.path) ?? false
                
            }) else {
                
                return (code: 400, nil, nil)
                
            }
            
            return (item.status, item.data, item.error)
            
        }
        
    }
    
}

NetworkInterceptor.setup()

let urlSession = URLSession.shared
let itunesRSSURL = URL(string: "https://rss.itunes.apple.com/api/v1/kr/apple-music/top-songs/all/50/explicit.json")!
let task = urlSession.dataTask(with: itunesRSSURL) { data, response, error in
    
    print(response as Any)
    
    guard let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) else {
        return
    }
    
    print(dictionary)
    
}

task.resume()


