//
//  SHAPIConstants.h
//  SHAPISDK
//
//  Created by Shakir Husain on 05/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SHAPIRequest;

@interface SHAPIConstants : NSObject

typedef void (^SHAPISuccessCallback) (id inResponseObj, SHAPIRequest* apiRequest);
typedef void (^SHAPIErrorCallback) (SHAPIRequest* apiRequest, NSError*  inError, long statusCode, NSString *reponseString);

typedef NS_ENUM(short, enAPIRequestType) {
    
    //*** least number is the Highest Priority ***//
    eAPIRequestWeather = 0,
    eAPIRequestFetchList ,
    eAPIRequestAllReqestCount //This is total counts of pririoty
};

typedef NS_ENUM(NSInteger,enReqContentType){
    
    eReqContentAppJson = 1,
    eReqContentAppXWWWForm,
    eReqContentTextPlain,
    eReqContentImage
};

typedef NS_ENUM(NSInteger,enReqMethodType){
    
    eReqPost = 1,
    eReqGet
};

@end


NS_ASSUME_NONNULL_END

FOUNDATION_EXTERN NSString *kReqPOST;
FOUNDATION_EXTERN NSString *kReqGET;
FOUNDATION_EXTERN NSString *kReqContentApplicationJson;
FOUNDATION_EXTERN NSString *kReqContentAppFormEncoded;
FOUNDATION_EXTERN NSString *kReqContentPlainText;
