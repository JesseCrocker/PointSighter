//
//  unitConversion.h
//  PitPod
//
//  Created by Jesse Crocker on 10/26/11.
//  Copyright (c) 2012 Jesse Crocker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface unitConversion : NSObject

+(NSNumber *)kgm3FromPercent:(NSNumber *)percent;
+(NSNumber *)metersFromFeet:(NSNumber *)feet;
+(NSNumber *)feetFromMeters:(NSNumber *)meters;
+(NSNumber *)cmFromInches:(NSNumber *)inches;
+(NSNumber *)tempCfromF:(NSNumber *)tempF;
+(NSNumber *)metersPerSecondFromMPH:(NSNumber *)mph;
+(NSNumber *)mbFromInHg:(NSNumber *)InHg;
+(NSString *)aspectStringFromDegrees:(NSNumber *)degreesNumber;
+(NSString *)degreeStringForAspect:(NSString *)aspectString;
+(NSNumber *)numberForAspect:(NSString *)aspectString;

@end
