//
//  SHRequestManager.h
//  SHAPISDK
//
//  Created by Shakir Husain on 05/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAPIConstants.h"

@class SHAPIRequest;

NS_ASSUME_NONNULL_BEGIN


@interface SHRequestManager : NSObject

+(SHAPIRequest *)requestForReqType:(enAPIRequestType)inReqType jsonObject:(id)inJsonObject andQueryStr:(NSString *)inStr ;

@end

NS_ASSUME_NONNULL_END
