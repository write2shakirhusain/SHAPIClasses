//
//  SHURLConfiguratin.m
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "SHURLConfiguration.h"

const NSString *kBaseURL = @"https://api.openweathermap.org/data/2.5/weather?";
const NSString *kApiKey1 = @"*** Add your subUrl here ***";

@implementation SHURLConfiguration

+(NSURL *)getUrlForRequestType:(enAPIRequestType)inReqType andQuery:(NSString *)inQueryStr{
    
    NSURL *aurl = nil;
    
    switch (inReqType) {
            
        case eAPIRequestWeather:{
            
            if (inQueryStr) {
                aurl = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kBaseURL,inQueryStr]];
            }else{
                aurl = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kBaseURL,kApiKey1]];
            }
        }
            break;
            
        case eAPIRequestFetchList:
            
            break;
            
        default:
            break;
    }
    return aurl;
}

@end
