//
//  SHURLConfiguratin.h
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAPIConstants.h"


NS_ASSUME_NONNULL_BEGIN

@interface SHURLConfiguration : NSObject

+(NSURL *)getUrlForRequestType:(enAPIRequestType)inReqType andQuery:(NSString *)inQueryStr;

@end

FOUNDATION_EXTERN NSString *kApiKey1;

NS_ASSUME_NONNULL_END
