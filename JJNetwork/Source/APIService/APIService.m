//
//  APIService.m
//  JJNetwork
//
//  Created by jezz on 30/07/2017.
//  Copyright © 2017 jezz. All rights reserved.
//

#import "APIService.h"
#import "APIManager.h"
#import "APIRequest.h"
#import "NSString+MD5.h"

@interface APIService ()

@property(nonatomic,readwrite,strong)NSURLSessionTask* taskRequest;

@property(nonatomic,readwrite,strong)id<APICache> apiCache;

@property(nonatomic,readwrite,copy)NSString* joinURL;

@end

@implementation APIService

- (instancetype)init{
    self = [super init];
    if (self) {
        self.apiCache = [[APIFileCache alloc] init];
    }
    return self;
}

- (void)dealloc{
    if (self.taskRequest != nil) {
        [self.taskRequest cancel];
    }
}

- (void)startRequest:(APIRequest<RequestProtocol>*)request{
    if (!request) {
        NSAssert(request != nil, @"Request object must not be nil");
        return;
    }
    if (![request conformsToProtocol:@protocol(RequestProtocol)]) {
        NSAssert([request conformsToProtocol:@protocol(RequestProtocol)],@"Request must implement RequestProtocol");
        return;
    }
    
    BOOL isSignParameter = NO;
    
    if ([request respondsToSelector:@selector(isSignParameter)]) {
        isSignParameter = [request isSignParameter];
    }
    
    NSDictionary* parameters = request.parameter;
    
    if (![request respondsToSelector:@selector(requestURL)]) {
        NSAssert([request respondsToSelector:@selector(requestURL)],@"Request must implement requestURL selector");
        return;
    }
    
    NSString* url = [request requestURL];
    
    HTTPMethod httpMethod = GET;
    if ([request respondsToSelector:@selector(requestMethod)]) {
        httpMethod = [request requestMethod];
    }
    
    //Handle cache
    
    self.joinURL = [self joinURL:url withParameter:parameters];
    id data = [self.apiCache cacheWithKey:self.joinURL];
    
    if (data != nil) {
        NSLog(@"Cache response delegate");
        if([self.serviceProtocol respondsToSelector:@selector(responseSuccess:responseData:)]){
            [self.serviceProtocol responseSuccess:self responseData:data];
        }
        return;
    }
    
    //Sign the parameter to safety
    if (isSignParameter && parameters) {
        parameters = [self signParameterWithKey:parameters key:[request signParameterKey]];
    }
    
    //Send http request
    
    if (httpMethod == GET){
        self.taskRequest = [[APIManager shareAPIManaer] httpGet:[NSURL URLWithString:url] parameter:parameters target:self selector:@selector(networkResponse:)];
    }else if(httpMethod == POST){
        self.taskRequest = [[APIManager shareAPIManaer] httpPost:[NSURL URLWithString:url] parameter:parameters target:self selector:@selector(networkResponse:)];
    }

}

- (void)networkResponse:(id)response{
	if ([response isKindOfClass:[NSError class]]) {
		//Handle Error
		if([self.serviceProtocol respondsToSelector:@selector(responseFail:errorMessage:)]){
			[self.serviceProtocol responseFail:self errorMessage:response];
		}
	}else{
        //Refresh cache cotent
        [self.apiCache saveCacheWithData:response withKey:self.joinURL];
        
		//Handle Content
		if([self.serviceProtocol respondsToSelector:@selector(responseSuccess:responseData:)]){
			[self.serviceProtocol responseSuccess:self responseData:response];
		}
	}
}

#pragma mark - Sign parameter with key

- (NSDictionary*)signParameterWithKey:(NSDictionary *)para key:(NSString*)key{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:para];
    
    NSMutableString* mString = [NSMutableString string];
    for (NSString* key in para) {
        NSString* value = para[key];
        [mString appendString:value];
    }
    
    //MD5 the all value and contact the timeStamp,
    //The sign will change every seconds
    
    [mString appendFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSString* sign = [[NSString stringWithFormat:@"%@%@",mString,key] md5];
    
    dic[@"sign"] = sign;
    return dic;
}

#pragma mark - Contact url and parameter

- (NSString*)joinURL:(NSString*)url withParameter:(NSDictionary*)parameter{
    if (!url) {
        return nil;
    }
    
    NSMutableString* string = [NSMutableString stringWithString:url];
    
    for (NSString* key in parameter) {
        [string appendString:key];
        [string appendString:parameter[key]];
    }
    return string;
}

@end
