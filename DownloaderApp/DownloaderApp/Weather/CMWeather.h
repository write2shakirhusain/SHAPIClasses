//
//  CMWeather.h
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMWeather : NSObject

@property(nonatomic , strong)NSString *cloudy;
@property(nonatomic , strong)NSString *humidity;
@property(nonatomic , strong)NSString *pressure;
@property(nonatomic , strong)NSString *temp;
@property(nonatomic , strong)NSString *country;
@property(nonatomic , strong)NSString *city;
@property(nonatomic , strong)NSString *dateStr;
@property(nonatomic , strong)NSString *timeStr;
@property(nonatomic , strong)NSString *visibility;

@property(nonatomic , strong)NSString *windSpeed;

-(instancetype)initWithJsonString:(NSString *)inJsonString;


@end
