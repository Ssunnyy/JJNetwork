//
//  APIRequest.h
//  JJNetwork
//
//  Created by jezz on 30/07/2017.
//  Copyright © 2017 jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,HTTPMethod){
	POST,
	GET,
	PUT,
	DELETE,
};

@protocol RequestProtocol <NSObject>

@required

- (NSString*)requestURL;

@optional


/**
 * Default request method is GET
 
 * @return HTTPMethod
 */
- (HTTPMethod)requestMethod;


/**
 * Sign the parameter with key
 * Default value is NO

 @return YES or NO
 */
- (BOOL)isSignParameter;

- (NSString*)signParameterKey;

@end

@interface APIRequest : NSObject

@end
