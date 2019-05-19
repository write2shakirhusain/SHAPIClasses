//
//  SHAPIRequest.m
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "SHAPIRequest.h"
#import "SHAPIManager.h"


const float kAPIRequestTimeout = 60;
const float kAPIRetryDelayTime = 10.0;

@interface SHAPIRequest() <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property(nonatomic, strong) NSString *reqContentTypeStr;
@property(nonatomic, strong) NSString *reqMethodTypeStr;

@property(nonatomic , assign) short retryCount;

@end

@implementation SHAPIRequest

-(instancetype)initWithURL:(NSURL *)URL{
    
    self = [super initWithURL: URL];
    
    if(self){
        
        //defualt Values
        self.requestSequence = NSNotFound;
        self.reqContentType = eReqContentAppJson;
        self.reqMethodType = eReqPost;
        self.retryCount = 1;
        self.totalRetryCount = 3;
      
    }
    return self;
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableDictionary *)requestDict {
    
    if (_requestDict == nil) {
        _requestDict = [[NSMutableDictionary alloc] init];
        
    }
    return _requestDict;
}

- (void)doExpireRequest {
    if (self.didExpireRequestBlock) {
        self.didExpireRequestBlock( self);
    }
}

-(NSString *)reqContentTypeStr{
    
    NSString * aReqContentType = nil;
    
    switch (self.reqContentType) {
        case eReqContentAppJson:
            aReqContentType = kReqContentApplicationJson;
            break;
            
        case eReqContentAppXWWWForm:
            aReqContentType = kReqContentAppFormEncoded;
            break;
            
        case eReqContentTextPlain:
            aReqContentType = kReqContentPlainText;
            break;
            
        default:
            break;
    }
  
    return aReqContentType;
}

-(NSString *)reqMethodTypeStr{
   
    NSString * aReqMethodType = nil;
    
    switch (self.reqMethodType) {
        case eReqGet:
            aReqMethodType = kReqGET;
            break;
            
        case eReqPost:
            aReqMethodType = kReqPOST;
            break;
            
        default:
            break;
    }
    return aReqMethodType;
}

- (void)sendRequest {
    
    [self setHTTPMethod: self.reqMethodTypeStr];
    [self setAllHTTPHeaderFields:@{ @"content-type": self.reqContentTypeStr}];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config delegate: self delegateQueue:[NSOperationQueue mainQueue]];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:self completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (error) {
                if (error && self.apiErrorCallBack) {
                    NSLog(@"error = %@",error.description);
                    self.apiErrorCallBack(self, error, 503,[error localizedDescription]);
                }
                
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                NSError *error = nil;
                id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                long statusCode = (long)[httpResponse statusCode];
                if (statusCode == 200) {
                    [self getDataForSuccessResponse:jsonData andResponseIdentifier:self.apiKey jsonString:responseString];
                }
                else {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kAPIRetryDelayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self retrySendRequest];
                    });
                    if (self.apiErrorCallBack) {
                        self.apiErrorCallBack(self, error, statusCode, responseString);
                    }
                }
            }
        });
    }];
    
    self.currentTask = dataTask;
    [dataTask resume];
}

-(void)retrySendRequest{
   
    if ([[SHAPIManager sharedInstance]isInternetAvailable]) {
       
        if (self.retryCount <= self.totalRetryCount) {
            NSLog(@"retry Count %i",self.retryCount);
            [self sendRequest];
            self.retryCount++;
            
        }else{
            [self doExpireRequest];
        }

    }
}

- (void)getDataForSuccessResponse:(id)inResponseDict andResponseIdentifier:(NSString *)inReqIdentifier jsonString:(NSString *)inJsonString{
    
    self.jsonStringResponse = inJsonString;
    
    if (self.apiSuccessCallBack) {
        self.apiSuccessCallBack(inResponseDict, self);
    }
    self.isExecuted = YES;
    
    if (self.didExecutedRequestBlock) {
        self.didExecutedRequestBlock(self);
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
    if([challenge.protectionSpace.authenticationMethod
        isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if([challenge.protectionSpace.host
            isEqualToString:@"api.openweathermap.org"])//gAppHeader.domainName
        {
            NSURLCredential *credential =
            [NSURLCredential credentialForTrust:
             challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    
}

+ (NSString *)generateUUID{
    
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid)
    {
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    return result;
}
@end

