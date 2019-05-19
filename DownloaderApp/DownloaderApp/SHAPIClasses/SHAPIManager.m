//
//  SHAPIManager.m
//  SHAPISDK
//
//  Created by Shakir Husain on 03/12/18.
//  Copyright © 2018 Shakir Husain. All rights reserved.
//

#import "SHAPIManager.h"
#import "SHAPIRequest.h"
#import "Reachability.h"

@interface SHAPIManager ()<NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate> {
    dispatch_queue_t shapiMgrQueue;
    void *shapiMgrQueueTag;
}

@property(nonatomic , strong) NSMutableArray *allExecutingRequests;
@property(nonatomic , strong) NSMutableArray *allRequests;
@property(nonatomic , assign) BOOL isProcessStarted;
@property(nonatomic , assign) NSInteger requestSequence;
@property(nonatomic , strong) Reachability *internetReach;

@end

@implementation SHAPIManager

+(SHAPIManager*)sharedInstance{
    
    static dispatch_once_t onceToken;
    static SHAPIManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        
        if (sharedInstance == nil){
            sharedInstance = [[SHAPIManager alloc] init];
            
        }
    });
    return  sharedInstance;
    
}

-(instancetype)init{
    
    self = [super init];
    if (self) {

        shapiMgrQueueTag = &shapiMgrQueueTag;
        shapiMgrQueue = dispatch_queue_create("shapiMgr", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(shapiMgrQueue, shapiMgrQueueTag, shapiMgrQueueTag, NULL);

        [self addObservers];
        [self initializeObjectIfNeeded];
    }
    return self;
}

-(void)dealloc{
    
    dispatch_block_t block = ^{
        
        [[NSNotificationCenter defaultCenter] removeObserver: self name:nil object:nil];
        [self.internetReach stopNotifier];
    };
  
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);

}

-(void)initializeObjectIfNeeded{
   
    dispatch_block_t block = ^{
        
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)addObservers{
    
    dispatch_block_t block = ^{
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(listenerForInternetConnectionListener:) name: kReachabilityChangedNotification object: nil];
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

- (NSMutableArray *)allExecutingRequests {
    
    
    dispatch_block_t block = ^{
        
        if (self->_allExecutingRequests == nil) {
            self->_allExecutingRequests = [[NSMutableArray alloc] initWithCapacity: eAPIRequestAllReqestCount];
        }
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);

    
    return self->_allExecutingRequests;
}

-(NSMutableArray *)allRequests{
    
    dispatch_block_t block = ^{
        
        if (self->_allRequests == nil) {
            self->_allRequests = [[NSMutableArray alloc] initWithCapacity: eAPIRequestAllReqestCount];
        }
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
    
    return self->_allRequests;

}

- (void)insertAPIRequestInProcess:(SHAPIRequest *)inRequest andRequestCallBack:(SHAPISuccessCallback)inCallBack error:(SHAPIErrorCallback)inError {
    
    dispatch_block_t block = ^{
        
        if ([self discardDuplicateRequest:inRequest] == NO) {
            
            inRequest.apiSuccessCallBack = inCallBack;
            inRequest.apiErrorCallBack = inError;
            
            [self.allRequests addObject: inRequest];
            if (inRequest.requestSequence == NSNotFound) {
                inRequest.requestSequence = self.requestSequence++;
            }
            [self sortAllRequestAscendingOrderByPriority];
            [self startRequestProcessing];
        }
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)processRequest:(SHAPIRequest *)inRequest{
    
    if (inRequest && self.isProcessStarted) {
        
        if ([self canProcessRequest: inRequest]) {
            
            [inRequest sendRequest];
            [self addRequestInExecutingQueue: inRequest];
           
            inRequest.didExpireRequestBlock = ^(SHAPIRequest * _Nonnull inRequest) {
                [self expiredRequest : inRequest];
            };
           
            inRequest.didExecutedRequestBlock = ^(SHAPIRequest * _Nonnull inRequest) {
                [self removeExecutedRequest: inRequest];
            };
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self processRequest: [self getRequestForProcessing]];
        });
    }
    else{
        self.isProcessStarted = NO;
    }
}

- (BOOL)discardDuplicateRequest:(SHAPIRequest *)inRequest {
    
    BOOL toReturn = NO;
    SHAPIRequest *aRequest = [self getRequestFromAllRequestForId: inRequest];
    
    if (aRequest) {
        //TODO:
    }
    return toReturn;
}

- (void)startRequestProcessing {
    
    if (self.isProcessStarted == NO) {
        self.isProcessStarted = YES;
        [self processRequest: [self getRequestForProcessing]];
    }
}

- (void)stopRequestProcessing {
    
    self.isProcessStarted = NO;
    [self moveAllExecutingRequestsInAllRequestWithError];
    
}

-(BOOL)canProcessRequest:(SHAPIRequest *)inRequest{
    
    BOOL toReturn = NO;
    
    if ([self isInternetAvailable]) {

        //TODO:
        toReturn = YES;

    }
    
    return toReturn;
}

-(BOOL)isAllRequestDone{
    
    BOOL toReturn = NO;
    
    if (self.allRequests.count == 0 && self.allExecutingRequests.count == 0) {
        toReturn = YES;
    }
    return  toReturn;
}

-(void)sortAllRequestAscendingOrderByPriority{
    

    dispatch_block_t block = ^{
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"requestSequence" ascending: YES];
        [self.allRequests sortUsingDescriptors:[NSArray arrayWithObject: sortDesc]];

    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
    
}

-(void)removeExecutedRequest:(SHAPIRequest *)inRequest{
  
    dispatch_block_t block = ^{
        [self.allExecutingRequests removeObject: inRequest];
    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)addRequestInExecutingQueue:(SHAPIRequest *)inRequest{
    
    dispatch_block_t block = ^{
        [self.allRequests removeObject: inRequest];
        [self.allExecutingRequests addObject : inRequest];
    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)moveRequestToAllRequestQueue:(SHAPIRequest *)inRequest{
    
    dispatch_block_t block = ^{
        
        if ([self discardDuplicateRequest: inRequest] == NO) {
            [self.allRequests addObject : inRequest];
            [self sortAllRequestAscendingOrderByPriority];
        }
    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)moveAllExecutingRequestsInAllRequestWithError{
    
    dispatch_block_t block = ^{
        
        for (SHAPIRequest *aRequest in self.allExecutingRequests) {
            [self moveRequestToAllRequestQueue: aRequest];
        }
        [self.allExecutingRequests removeAllObjects];

    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

- (SHAPIRequest *)getRequestForProcessing {
   
    __block SHAPIRequest *aRequest = nil;
    
    dispatch_block_t block = ^{
        
        aRequest = [self.allRequests firstObject];
    };
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
    
    return aRequest;
}

-(SHAPIRequest *)getExecutingRequestForId:(NSString *)inRequestId{
   
    __block SHAPIRequest *aRequest = nil;
    
    dispatch_block_t block = ^{
        
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"requestId == %@",inRequestId];
        NSArray  *filteredObjects = [self.allExecutingRequests filteredArrayUsingPredicate: aPredicate];
        
        if (filteredObjects && filteredObjects.count > 0) {
            aRequest = [filteredObjects firstObject];
        }
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);

    return aRequest;
}

- (SHAPIRequest *)getRequestFromAllRequestForId:(SHAPIRequest *)inRequest {
    
    __block SHAPIRequest *aRequest = nil;
    
    dispatch_block_t block = ^{
        
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"requestType == %d AND requestId == %@",inRequest.requestType,inRequest.requestId];
        
        NSMutableSet *allReq = nil;
        
        if (self.allRequests.count >0) {
            allReq = [[NSMutableSet alloc] initWithArray: self.allRequests];
        }
        if (self.allExecutingRequests.count >0) {
            [allReq addObjectsFromArray: self.allExecutingRequests];
        }
        
        NSArray  *filteredObjects = [allReq.allObjects filteredArrayUsingPredicate: aPredicate];
        
        if (filteredObjects && filteredObjects.count > 0) {
            aRequest = [filteredObjects firstObject];
        }
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
    return aRequest;
    
}

- (void)listenerForInternetConnectionListener:(NSNotification *)inNotification{
    
    dispatch_block_t block = ^{
        
        if ([[inNotification name] isEqualToString: kReachabilityChangedNotification]) {
            
            if([self isInternetAvailable]){
                [self startRequestProcessing];
            }
            else{
                [self stopRequestProcessing];
            }
        }

    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}

-(void)expiredRequest:(SHAPIRequest *)inRequest{
    
    dispatch_block_t block = ^{
        
        [self moveRequestToAllRequestQueue: inRequest];
    };
    
    if (dispatch_get_specific(shapiMgrQueueTag))
        block();
    else
        dispatch_sync(shapiMgrQueue, block);
}


#pragma mark-
#pragma mark - Utils

+(BOOL)isPreAuthenticatedAPIRequest:(id)inRequest {
    
    SHAPIRequest *aRequest = inRequest;
    
    if (aRequest.requestType < eAPIRequestFetchList) {
        return YES;
    }
    return NO;
}

-(void)discardAllRequest{
    
    for (SHAPIRequest *aRequest in self.allExecutingRequests) {
        aRequest.isExecuted = YES;
        [aRequest.currentTask cancel];
        
    }
    [self.allRequests removeAllObjects];
    [self.allExecutingRequests removeAllObjects];
    
}

+ (id)convertJsonIntoDictionary:(NSString *)inResponse {
    
    NSError *jsonError;
    NSData *objectData = [inResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (json) {
        return json;
    }
    return nil;
}


#pragma mark- Network reachabiliyt
- (BOOL)isInternetAvailable
{
    BOOL isInternetAvailable = false;
    NetworkStatus netStatus = [self.internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            isInternetAvailable = FALSE;
            break;
        case ReachableViaWWAN:
            isInternetAvailable = TRUE;
            break;
        case ReachableViaWiFi:
            isInternetAvailable = TRUE;
            break;
    }
    return isInternetAvailable;
}

@end
