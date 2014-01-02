//
//  pointAnnotation.h
//  PitPod
//
//  Created by Jesse Crocker on 9/22/11.
//  Copyright (c) 2012 Jesse Crocker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mapPoint: NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
