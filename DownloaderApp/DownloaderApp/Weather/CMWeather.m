//
//  CMWeather.m
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "CMWeather.h"

@interface CMWeather(){
    
}

@end

@implementation CMWeather

-(instancetype)initWithJsonString:(NSString *)inJsonString{
   
    self = [super init];
    if (self) {
       
        NSData *data = [inJsonString dataUsingEncoding:NSUTF8StringEncoding];
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [self parseJsonString: responseObject];
    }
    return self;
}

-(void)parseJsonString:(NSDictionary *)inDataDict{
    
    if([inDataDict objectForKey:@"clouds"] && [[inDataDict objectForKey:@"clouds"] isKindOfClass:[NSNull class]] == NO) {
        NSDictionary *aDict =  [inDataDict objectForKey:@"clouds"];
        self.cloudy = [NSString stringWithFormat:@"%@%%",[ aDict objectForKey:@"all"]];
    }
    if([inDataDict objectForKey:@"main"] && [[inDataDict objectForKey:@"main"] isKindOfClass:[NSNull class]] == NO) {
        
        NSDictionary *aDict =  [inDataDict objectForKey:@"main"];
        self.humidity = [NSString stringWithFormat:@"%@%%",[ aDict objectForKey:@"humidity"]];
        self.pressure = [ aDict objectForKey:@"pressure"];
        NSInteger aTemp = [[ aDict objectForKey:@"temp"] doubleValue] - 273.15;
        self.temp = [NSString stringWithFormat:@"%li℃",aTemp];
    }
    if([inDataDict objectForKey:@"name"] && [[inDataDict objectForKey:@"name"] isKindOfClass:[NSNull class]] == NO) {
        self.city = [ inDataDict objectForKey:@"name"];
    }
    if([inDataDict objectForKey:@"visibility"] && [[inDataDict objectForKey:@"visibility"] isKindOfClass:[NSNull class]] == NO) {
        NSInteger aVisibilty =  [[ inDataDict objectForKey:@"visibility"] doubleValue]/1000;
        self.visibility = [NSString stringWithFormat:@"%li km",aVisibilty];
    }

    if([inDataDict objectForKey:@"wind"] && [[inDataDict objectForKey:@"wind"] isKindOfClass:[NSNull class]] == NO) {
        NSDictionary *aDict =  [inDataDict objectForKey:@"wind"];
        NSInteger aWindSpeed = [ [ aDict objectForKey:@"speed"] doubleValue] * 3.6;//in km
        self.windSpeed = [NSString stringWithFormat:@"%li km/h",aWindSpeed] ;//in km
    }
    if([inDataDict objectForKey:@"sys"] && [[inDataDict objectForKey:@"sys"] isKindOfClass:[NSNull class]] == NO) {
        NSDictionary *aDict =  [inDataDict objectForKey:@"sys"];
        self.country = [ aDict objectForKey:@"country"];
    }
    
//    if([inDataDict objectForKey:@"dt"] && [[inDataDict objectForKey:@"dt"] isKindOfClass:[NSNull class]] == NO) {
//        NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:[[inDataDict objectForKey:@"dt"] doubleValue]];
//        self.dateStr = [Utils getDayDateMonthYear:aDate];
//        self.timeStr =  [Utils relativeDateStringMessageInfoForTime:aDate];;
//
//    }


}
@end
