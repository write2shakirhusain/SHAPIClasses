//
//  SHAPIRequest.h
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAPIConstants.h"

NS_ASSUME_NONNULL_BEGIN


@interface SHAPIRequest : NSMutableURLRequest

//for request purpose
@property(nonatomic, copy) SHAPISuccessCallback apiSuccessCallBack;
@property(nonatomic, copy) SHAPIErrorCallback apiErrorCallBack;
@property(nonatomic, assign) enAPIRequestType requestType;
@property(nonatomic, assign) enReqContentType reqContentType;
@property(nonatomic, assign) enReqMethodType reqMethodType;
@property(nonatomic, strong) NSString * apiKey;
@property(nonatomic, strong) NSString * requestId;
@property(nonatomic, strong) NSString  *queryString;
@property(nonatomic, strong) NSMutableDictionary * requestDict;
@property(nonatomic, assign) NSInteger requestSequence;
@property(nonatomic , assign) short totalRetryCount;

//for respose purpose
@property(nonatomic, assign) BOOL isExecuted;
@property(nonatomic, strong) NSString  *jsonStringResponse;
@property(nonatomic , strong) NSURLSessionDataTask *currentTask;
@property(nonatomic,copy)void(^didExecutedRequestBlock)(SHAPIRequest *inRequest);
@property(nonatomic,copy)void(^didExpireRequestBlock)(SHAPIRequest *inRequest);

+ (NSString *)generateUUID;
- (void)sendRequest;

@end

NS_ASSUME_NONNULL_END
