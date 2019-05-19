//
//  ViewController.m
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "ViewController.h"

#import "SHAPIHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
   
    SHAPIRequest *aRequest = [SHRequestManager requestForReqType:eAPIRequestWeather jsonObject: @{@"123":@"key"} andQueryStr: @"lat=28.7041&lon=77.1025&appid=aeefeef0d7423be2c612db7d634d3a95"];
   
    [[SHAPIManager sharedInstance] insertAPIRequestInProcess: aRequest andRequestCallBack:^(id  _Nonnull inResponseObj, SHAPIRequest * _Nonnull apiRequest) {
        
    } error:^(SHAPIRequest * _Nonnull apiRequest, NSError * _Nonnull inError, long statusCode, NSString * _Nonnull reponseString) {
        
    }];
}


@end
