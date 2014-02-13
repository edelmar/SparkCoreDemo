//
//  SparkCore.m
//  SparkCorePatternBlinkTest
//
//  Created by Eric G. DelMar on 2/10/14.
//  Copyright (c) 2014 Eric G. DelMar. All rights reserved.
//

#import "SparkCore.h"

@implementation SparkCore



+(instancetype)coreWithdeviceID:(NSString *) devID accessToken:(NSString *) accessToken {
    return [[self alloc] initWithdeviceID:devID accessToken:accessToken];
}


-(instancetype)initWithdeviceID:(NSString *) devID accessToken:(NSString *) accessToken {
    if (self = [super init]) {
        _deviceID = devID;
        _accessToken = accessToken;
    }
    return self;
}



+(instancetype)coreWithNewTokenNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password {
    return  [[self alloc] initCoreWithNewTokenNamed:coreName userName:user password:password];
}


-(instancetype)initCoreWithNewTokenNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password {
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:@"https://api.spark.io/oauth/token"];
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [postRequest setValue:@"Basic c3Bhcms6c3Bhcms=" forHTTPHeaderField:@"Authorization"];
        [postRequest setHTTPMethod:@"POST"];
        NSString *bodyData = [NSString stringWithFormat:@"grant_type=password&username=%@&password=%@",user,password];
        [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
        [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *error;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (dict) {
                    NSLog(@"%@",dict);
                    _accessToken = dict[@"access_token"];
                    [self downloadDeviceIDforCore:coreName];
                }
            }
        }];
    }
    return self;
}




+(instancetype)coreWithUserName:(NSString *) user password:(NSString *) password {
    return [[self alloc] initCoreNamed:@"" userName:user password:password];
}



+(instancetype)coreNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password {
    return [[self alloc] initCoreNamed:coreName userName:user password:password];
}



-(instancetype)initCoreNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password {
    if (self = [super init]) {
        NSURL *url = [NSURL URLWithString:@"https://api.spark.io/v1/access_tokens"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
        [request setHTTPMethod:@"GET"];
        NSString *userAndPassword = [NSString stringWithFormat:@"%@:%@",user,password];
        NSData *plainData = [userAndPassword dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        [request setValue:[NSString stringWithFormat:@"Basic %@",base64String] forHTTPHeaderField:@"Authorization"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *error;
                NSArray *tokenArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (tokenArray) {
                    NSLog(@"%@",tokenArray);
                    _accessToken = (tokenArray.count >1)? tokenArray[arc4random_uniform(tokenArray.count)][@"token"] : tokenArray[0][@"token"];
                    [self downloadDeviceIDforCore:coreName];
                }
            }else{
                NSLog(@"%@",connectionError);
            }
        }];
    }
    return self;
}



-(void)downloadDeviceIDforCore:(NSString *) coreName{
    NSString *s = [NSString stringWithFormat:@"https://api.spark.io/v1/devices?access_token=%@", _accessToken];
    NSURL *url = [NSURL URLWithString:s];
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [NSURLConnection sendAsynchronousRequest:getRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (array) {
                if (coreName.length == 0) {
                    _deviceID = array[0][@"id"];
                }else{
                    NSInteger indx = [array indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        return [obj[@"name"] isEqualToString:coreName];
                    }];
                    _deviceID = array[indx][@"id"];
                }
                [self.delegate deviceIDWasSet];
            }
        }
    }];
}



-(void) executeFunction:(NSString *)functionName argument:(NSString*) arg completionHandler:(void (^)(NSInteger result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@",self.deviceID,functionName]];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    NSString *bodyData = [NSString stringWithFormat:@"access_token=%@&params=%@",self.accessToken,arg];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (dict) {
                NSLog(@"%@",dict);
                NSInteger result = [dict[@"return_value"] integerValue];
                if (handler) {
                    handler(result,nil);
                }
            }else{
                handler(0, error);
            }
        }else{
            handler(0,connectionError);
        }
    }];
}


-(void) executeFunction:(NSString *)functionName argument:(NSString*) arg returnKeys:(NSArray *) keys completionHandler:(void (^)(NSDictionary *result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@",self.deviceID,functionName]];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    NSString *bodyData = [NSString stringWithFormat:@"access_token=%@&params=%@",self.accessToken,arg];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (dict) {
                NSLog(@"%@",dict);
                NSInteger returnInt = [dict[@"return_value"] integerValue];
                if (handler) {
                    NSInteger left16Int;
                    NSInteger right16Int;
                    NSInteger lowLeftInt;
                    NSInteger lowRightInt;
                    NSInteger highLeftInt;
                    NSInteger highRightInt;
                    NSDictionary *resultDict;
                    NSError *keyError;
                    switch (keys.count) {
                        case 1:
                            resultDict = @{keys[0]:@(returnInt)};
                            if (handler) handler(resultDict,nil);
                            break;
                        case 2:
                            left16Int = returnInt >> 16;
                            right16Int = returnInt & 0xffff;
                            resultDict = @{keys[0]:@(left16Int), keys[1]:@(right16Int)};
                            if (handler) handler(resultDict,nil);
                            break;
                        case 3:
                            left16Int = returnInt >> 16;
                            lowLeftInt = (returnInt >> 8) & 0xff;
                            lowRightInt = returnInt & 0xff;
                            resultDict = @{keys[0]:@(left16Int), keys[1]:@(lowLeftInt), keys[2]:@(lowRightInt)};
                            if (handler) handler(resultDict,nil);
                            break;
                        case 4:
                            highLeftInt = returnInt >> 24;
                            highRightInt = (returnInt >> 16) & 0xff;
                            lowLeftInt = (returnInt >> 8) & 0xff;
                            lowRightInt = returnInt & 0xff;
                            resultDict = @{keys[0]:@(highLeftInt), keys[1]:@(highRightInt), keys[2]:@(lowLeftInt), keys[3]:@(lowRightInt)};
                            if (handler) handler(resultDict,nil);
                            break;
                        default:
                            keyError = [NSError errorWithDomain:@"KeyRangeError" code:47 userInfo:@{NSLocalizedDescriptionKey:@"ERROR: The keys array must contain between 1 and 4 strings"}];
                            break;
                    }
                }
            }else{
                handler(nil, error);
            }
        }else{
            handler(nil, connectionError);
        }
    }];
}


-(void)readInt:(NSString *)variable completionHandler:(void (^)(int result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@?access_token=%@",self.deviceID, variable, self.accessToken]];
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [NSURLConnection sendAsynchronousRequest:getRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (dict) {
                handler([dict[@"result"] integerValue], nil);
            }else{
                handler(NSIntegerMax, jsonError);
            }
        }else{
            handler(NSIntegerMax, connectionError);
        }
    }];
}




-(void)readBoolean:(NSString *)variable completionHandler:(void (^)(BOOL result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@?access_token=%@",self.deviceID, variable, self.accessToken]];
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [NSURLConnection sendAsynchronousRequest:getRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (dict) {
                handler([dict[@"result"] boolValue], nil);
            }else{
                handler(NO, jsonError);
            }
        }else{
            handler(NO, connectionError);
        }
    }];
}





-(void)readDouble:(NSString *)variable completionHandler:(void (^)(double result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@?access_token=%@",self.deviceID, variable, self.accessToken]];
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [NSURLConnection sendAsynchronousRequest:getRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (dict) {
                handler([dict[@"result"] doubleValue], nil);
            }else{
                handler(NSIntegerMax, jsonError);
            }
        }else{
            handler(NSIntegerMax, connectionError);
        }
    }];
}





-(void)readString:(NSString *)variable completionHandler:(void (^)(NSString *result, NSError *error))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spark.io/v1/devices/%@/%@?access_token=%@",self.deviceID, variable, self.accessToken]];
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 10.0];
    [NSURLConnection sendAsynchronousRequest:getRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (dict) {
                handler(dict[@"result"], nil);
            }else{
                handler(nil, jsonError);
            }
        }else{
            handler(nil, connectionError);
        }
    }];
}






@end
