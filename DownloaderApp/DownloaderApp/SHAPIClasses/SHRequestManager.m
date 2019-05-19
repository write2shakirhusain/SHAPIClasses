//
//  SHRequestManager.m
//  SHAPISDK
//
//  Created by Shakir Husain on 05/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "SHRequestManager.h"
#import "SHAPIRequest.h"
#import "SHURLConfiguration.h"

@implementation SHRequestManager

+(SHAPIRequest *)requestForReqType:(enAPIRequestType)inReqType jsonObject:(id)inJsonObject andQueryStr:(NSString *)inStr{

    SHAPIRequest *aRequest = nil;
    switch (inReqType) {
        
        case eAPIRequestWeather:
            aRequest = [SHRequestManager createRequestForLoginWithData: inJsonObject andQueryStr: inStr];
            break;
            //***add onther request type
        default:
            break;
    }
    aRequest.requestId = [SHAPIRequest generateUUID];
    aRequest.requestType = inReqType;
    return aRequest;
}

+(SHAPIRequest *)createRequestForLoginWithData:(id)inReqData andQueryStr:(NSString *)inStr{
  
    SHAPIRequest *aRequest = [[SHAPIRequest alloc] initWithURL: [SHURLConfiguration getUrlForRequestType: eAPIRequestWeather andQuery: inStr]];
    aRequest.queryString = inStr;
    aRequest.apiKey = kApiKey1;
    [aRequest.requestDict addEntriesFromDictionary: inReqData];
    aRequest.reqMethodType = eReqGet;
    
    return  aRequest;
}


@end
