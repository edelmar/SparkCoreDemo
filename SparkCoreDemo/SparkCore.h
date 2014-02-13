//
//  SparkCore.h
//  SparkCorePatternBlinkTest
//
//  Created by Eric G. DelMar on 2/10/14.
//  Copyright (c) 2014 Eric G. DelMar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SparkCoreDelegate <NSObject>

-(void)deviceIDWasSet;

@end

@interface SparkCore : NSObject


@property (strong,nonatomic) NSString *deviceID;
@property (strong,nonatomic) NSString *accessToken;
@property (weak,nonatomic) id<SparkCoreDelegate>  delegate;

// Use one of these methods to create a SparkCore object with a particular name. If you have more than one core, you should use this method, not coreWithUserName:password:
// If you have more than one access token, this method will pick a random one of those to use for accessing the core
// This will assign the correct deviceID based on the name of your core which allows you to easily use more than one core in the same app
+(instancetype)coreNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password;
-(instancetype)initCoreNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password;


// Creates a SparkCore object as the above two methods, but creates a new access token, rather than using an existing one
// This will create a new access token each time you instnatiate a SparkCore object, so be aware that you will be adding new tokens each time you run the app
+(instancetype)coreWithNewTokenNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password;
-(instancetype)initCoreWithNewTokenNamed:(NSString *)coreName userName:(NSString *) user password:(NSString *) password;


// You can use this method if you only have one core. It will assign the single deviceID available to your core object.
+(instancetype)coreWithUserName:(NSString *) user password:(NSString *) password;


// Use one of these if you want to hard code the values of device ID and access token rather than going out to the cloud to get these values based on your user name and password
+(instancetype)coreWithdeviceID:(NSString *) devID accessToken:(NSString *) accessToken;
-(instancetype)initWithdeviceID:(NSString *) devID accessToken:(NSString *) accessToken;



// Use one of these two methods to control the core. The first one returns a single (32 bit) integer in the completion handler or an NSError object if the command fails
// The second method parse the 32 bit returned integer into pieces so you can return multiple values with one call to the core
// The number (in the range 1 to 4) of keys you pass determines how the number is parsed. If you pass two strings, the result is split into two 16 bit integers.
// If you pass 3 strings the result is parsed into a 16 bit integer and two 8 bit integers. If you pass 4, you get four 8 bit integers
// The result returned in the completion handler will be a dictionary whose keys will be the strings you passed in the returnKeys array, and
// the values will be the parsed integers. The values are assigned from the most significant bits to the least, so, for example,
// if you pass 3 key strings, the value for the first key will be the 16 most significant bits of the the 32 bit integer, the value for the
// second key string will be the next 8 bits, and the last key's value will be the 8 least significant bits.
// Be aware that the SparkCore returns a signed 32 bit integer, so the largest number you can pass is 2,147,483,647 (2^32/2 - 1)
-(void) executeFunction:(NSString *)functionName argument:(NSString*) arg completionHandler:(void (^)(NSInteger result, NSError *error))handler ;
-(void) executeFunction:(NSString *)functionName argument:(NSString*) arg returnKeys:(NSArray *) keys completionHandler:(void (^)(NSDictionary *result, NSError *error))handler;


// Use these to read the value of a Spark variable. The four methods correspond to the four allowable Spark variable data types. The readInt: and readDouble: methods
// return NSIntegerMax and an NSError object if there is an error, so you should check to see if the error parameter is nil before using the result.
// readBoolean: returns NO and an NSError object if there's an error, and the readString: method returns nil for the result and an NSError object if an error occers.
-(void) readInt:(NSString *) variable completionHandler:(void (^)(int result, NSError *error))handler;
-(void) readBoolean:(NSString *) variable completionHandler:(void (^)(BOOL result, NSError *error))handler;
-(void) readDouble:(NSString *) variable completionHandler:(void (^)(double result, NSError *error))handler;
-(void) readString:(NSString *) variable completionHandler:(void (^)(NSString *result, NSError *error))handler;


@end
