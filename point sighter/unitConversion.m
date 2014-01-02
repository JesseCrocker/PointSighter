//
//  unitConversion.m
//  PitPod
//
//  Created by Jesse Crocker on 10/26/11.
//  Copyright (c) 2012 Jesse Crocker. All rights reserved.
//

#import "unitConversion.h"

@implementation unitConversion
+(NSNumber *)kgm3FromPercent:(NSNumber *)percent{
    return [NSNumber numberWithDouble:([percent doubleValue] * 10)];
}
+(NSNumber *)metersFromFeet:(NSNumber *)feet{
    double input = [feet doubleValue];
    return [NSNumber numberWithDouble:input/3.28];
}
+(NSNumber *)feetFromMeters:(NSNumber *)meters{
    double input = [meters doubleValue];
    return [NSNumber numberWithDouble:input * 3.28];
}
+(NSNumber *)cmFromInches:(NSNumber *)inches{
    double input = [inches doubleValue];
    return [NSNumber numberWithDouble:input * 2.54];
}
+(NSNumber *)tempCfromF:(NSNumber *)tempF{
    return [NSNumber numberWithDouble:(([tempF doubleValue] - 32) * 5.0/9.0)];
}
+(NSNumber *)metersPerSecondFromMPH:(NSNumber *)mph{
    return [NSNumber numberWithDouble:([mph doubleValue] * 0.447)];    
}
+(NSNumber *)mbFromInHg:(NSNumber *)InHg{
    return [NSNumber numberWithDouble:([InHg doubleValue] * 33.86)];    
}
+(NSString *)aspectStringFromDegrees:(NSNumber *)degreesNumber{
    CGFloat degrees = [degreesNumber floatValue];
    bool moreDirections = YES;
    NSString *out = @"";
    if(moreDirections){
        NSArray *directions = [[NSArray alloc] initWithObjects:@"N", @"NNE", @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE", @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW", @"N" , nil];
        for(int i = 0; i < [directions count]; i++){
            if (degrees < 11.25 + (22.5 * i)){
                out =  [directions objectAtIndex:i];
                break;
            }
        }
        [directions release];
    }else{
        NSArray *directions = [[NSArray alloc] initWithObjects:@"N",  @"NE",  @"E",  @"SE",  @"S",  @"SW",  @"W",  @"NW", @"N", nil];
        for(int i = 0; i < [directions count]; i++){
            if (degrees < 22.5 + (45 * i)){
                out = [directions objectAtIndex:i];
                break;
            }
        }
        [directions release];
    }
    return out;
}

+(NSString *)degreeStringForAspect:(NSString *)aspectString{
    return [NSString stringWithFormat:@"%i", [[unitConversion numberForAspect:aspectString] intValue]];
}
+(NSNumber *)numberForAspect:(NSString *)aspectString{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *parsed = [numberFormatter numberFromString:aspectString];
    [numberFormatter release];
    
    if(parsed != nil ){//if its already a number
        if([parsed intValue] >= 0 && [parsed intValue] <= 360)
            return [NSString stringWithFormat:@"%i", [parsed intValue]];
        else
            return nil;
    }
    
    NSInteger aspect = -1;
    NSArray *directions = [[NSArray alloc] initWithObjects:@"N", @"NNE", @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE", @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW", @"N" , nil];
    for(int i = 0; i < [directions count]; i++){
        if([aspectString isEqualToString:[directions objectAtIndex:i]]){
            aspect = 22.5 * i;
            break;
        }
    }
    [directions release];
    if(aspect == -1)
        return nil;
    
    return [NSNumber numberWithInt:aspect];
}
@end
