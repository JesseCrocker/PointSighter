//
//  ViewController.h
//  point sighter
//
//  Created by Jesse Crocker on 5/17/12.
//  Copyright (c) 2012 Jesse Crocker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "unitConversion.h"
#import "mapPoint.h"

#define kFilteringFactor 0.05
#define updateFrequency 1.0f/10.0f

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate,
CLLocationManagerDelegate, UIAccelerometerDelegate>

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UIView *cameraView;
@property (retain, nonatomic) IBOutlet UIPickerView *distancePicker;
@property (retain, nonatomic) IBOutlet UILabel *myElevationLabel;
@property (retain, nonatomic) IBOutlet UILabel *myElevationAccuracyLabel;
@property (retain, nonatomic) IBOutlet UILabel *sightedElevationLabel;
@property (retain, nonatomic) IBOutlet UILabel *sightedElevationLabelLabel;
@property (retain, nonatomic) IBOutlet UILabel *sightedLatLonLabel;
@property (retain, nonatomic) IBOutlet UIImageView *compassImageView;
@property (retain, nonatomic) IBOutlet UILabel *errorLabel;
@property (retain, nonatomic) IBOutlet UILabel *currentHeadingLabel;
@property (retain, nonatomic) IBOutlet UIView *locationInfoView;
@property (retain, nonatomic) IBOutlet UIView *mapContainer;
@property (retain, nonatomic) IBOutlet UIImageView *horizonLineImage;
@property (retain, nonatomic) IBOutlet UILabel *distancePickerUnitLabel;
@property (retain, nonatomic) IBOutlet UIButton *lockButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, retain) UIImage *redLine;
@property (nonatomic, retain) UIImage *yellowLine;
@property (nonatomic, retain) UIImage *greenLine;

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) AVCaptureSession *captureSession;

@property (assign) CGFloat currentAngleFloat;
@property (assign) CGFloat lastAngleFloat;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (assign) CLLocationCoordinate2D sightedCoordinate;
@property (assign) CLLocationDirection currentHeading;
@property (assign) CLLocationDistance distance;
@property (assign) CLLocationDistance sightedElevation;
@property (nonatomic, retain) MKPolyline *sightLine;
@property (nonatomic, retain) MKPolylineView *sightLineView;
@property (nonatomic, retain) mapPoint *sightedPoint;
@property (assign) CGFloat currentHorizonAngle;
@property (assign) bool hold;
@property (assign) bool tilted;
@property (nonatomic, retain) NSArray *distanceOptions;
@property (nonatomic, retain) NSString *distanceUnit;

@property (assign) bool showSightedElevation;
@property (assign) bool showLocationInfo;
@property (nonatomic, retain) NSManagedObject *objectToSet;

-(void)startCameraPreview;
-(void)stopCameraPreview;
-(void)updateSightedPoint;
-(CGFloat)radiansToDegrees:(CGFloat)radians;
-(CGFloat)degreesToRadians:(CGFloat)degrees;
-(CGFloat)calibratedAngleFromAngle:(CGFloat)angle;
-(NSString *)convertDegreesToDirection:(CGFloat)degrees;
-(void)zoomToLocation:(CLLocation *)newLocation;
-(BOOL) CLLocationCoordinate2DEquals:(const CLLocationCoordinate2D)lhs withSecondCoordinate:(const CLLocationCoordinate2D)rhs;
-(CLLocationCoordinate2D)destinationCoordinateOnRhumbLineUsingBearing:(CLLocationDirection)bearing
                                                              andDistance:(CLLocationDistance)distanceToPoint 
                                                                fromPoint:(CLLocationCoordinate2D)startingCoord;
-(void)drawSightedPoint;
-(void)drawSightLine;
- (IBAction)lockButtonPressed:(id)sender;
- (IBAction)saveButtonPressed;
-(void)calculateSightedElevation;

@end
