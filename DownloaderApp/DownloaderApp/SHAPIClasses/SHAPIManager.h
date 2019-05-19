//
//  SHAPIManager.h
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAPIConstants.h"

NS_ASSUME_NONNULL_BEGIN


@class SHAPIRequest;

@interface SHAPIManager : NSObject

+ (SHAPIManager*)sharedInstance;
- (void)insertAPIRequestInProcess:(SHAPIRequest*)inRequest andRequestCallBack:(SHAPISuccessCallback)inCallBack error:(SHAPIErrorCallback)inError;

-(void)discardAllRequest;
- (BOOL)isInternetAvailable;
@end

NS_ASSUME_NONNULL_END
