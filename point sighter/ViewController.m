//
//  ViewController.m
//  point sighter
//
//  Created by Jesse Crocker on 5/17/12.
//  Copyright (c) 2012 Jesse Crocker. All rights reserved.
//

//todo:
//Zoom to make sure that the whole line is on screen
//do something with sighted elevation display, proably get rid of it

#import "ViewController.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0 / M_PI))
#define EARTH_RADIUS 6371009.0; // Earth radius in meters (same unit as d) (Using mean radius as defined on Wikipedia)

@implementation MKMapView (Additions)

- (UIImageView*) googleLogo {
    
    UIImageView *imgView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            imgView = (UIImageView*)subview;
            [imgView retain];
            [imgView removeFromSuperview];
            break;
        }
    }
    return imgView;
}

@end

@implementation ViewController
@synthesize mapView;
@synthesize cameraView;
@synthesize distancePicker;
@synthesize myElevationLabel;
@synthesize myElevationAccuracyLabel;
@synthesize sightedElevationLabel;
@synthesize sightedElevationLabelLabel;
@synthesize sightedLatLonLabel;
@synthesize compassImageView;
@synthesize errorLabel;
@synthesize currentHeadingLabel;
@synthesize locationInfoView;
@synthesize mapContainer;
@synthesize horizonLineImage;
@synthesize distancePickerUnitLabel;
@synthesize lockButton;
@synthesize saveButton;

@synthesize greenLine;
@synthesize redLine;
@synthesize yellowLine;

@synthesize locationManager;
@synthesize captureSession;

@synthesize currentAngleFloat;
@synthesize lastAngleFloat;
@synthesize currentHeading;
@synthesize currentLocation;
@synthesize sightedCoordinate;
@synthesize distance;
@synthesize sightLine;
@synthesize sightLineView;
@synthesize sightedPoint;
@synthesize currentHorizonAngle;
@synthesize sightedElevation;

@synthesize hold;
@synthesize tilted;
@synthesize showLocationInfo;
@synthesize showSightedElevation;
@synthesize distanceOptions;
@synthesize distanceUnit;

@synthesize objectToSet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *gLogo = [self.mapView googleLogo];
    gLogo.frame = CGRectMake(0, (self.mapContainer.frame.size.height),
                             gLogo.frame.size.width, gLogo.frame.size.height);
    [self.mapContainer addSubview:gLogo];
    currentHeadingLabel.layer.cornerRadius = 8;
    self.showLocationInfo = YES;
    self.showSightedElevation = YES;
    //self.distanceUnit = @"F";
}

- (void)viewDidUnload
{
    self.mapView.delegate = nil;
    [self setMapView:nil];
    [self setCameraView:nil];
    [self setDistancePicker:nil];
    [self setMyElevationLabel:nil];
    [self setMyElevationAccuracyLabel:nil];
    [self setSightedElevationLabel:nil];
    [self setSightedLatLonLabel:nil];
    [self setCompassImageView:nil];
    [self setErrorLabel:nil];
    [self setCurrentHeadingLabel:nil];
    [self setLocationInfoView:nil];
    [self setMapContainer:nil];
    [self setHorizonLineImage:nil];
    [self setDistancePickerUnitLabel:nil];
    [self setLockButton:nil];
    [self setSightedElevationLabelLabel:nil];
    [self setSaveButton:nil];
    
    self.greenLine = nil;
    self.yellowLine = nil;
    self.redLine = nil;
    
    [captureSession stopRunning];
    self.captureSession = nil;
    
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    self.currentLocation = nil;
    self.sightLine = nil;
    self.sightLineView = nil;
    self.sightedPoint = nil;
    self.distanceOptions = nil;
    self.distanceUnit = nil;
    self.objectToSet = nil;
    
    UIAccelerometer *acceleromter = [UIAccelerometer sharedAccelerometer];
	acceleromter.delegate = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.mapView.delegate = nil;
    [mapView release];
    [cameraView release];
    [distancePicker release];
    [myElevationLabel release];
    [myElevationAccuracyLabel release];
    [sightedElevationLabel release];
    [sightedLatLonLabel release];
    [errorLabel release];
    [currentHeadingLabel release];
    [locationInfoView release];
    [mapContainer release];
    [horizonLineImage release];
    [distancePickerUnitLabel release];
    [lockButton release];
    [sightedElevationLabelLabel release];
    [saveButton release];
    
    [redLine release];
    [yellowLine release];
    [greenLine release];
    
    [captureSession stopRunning];
    self.captureSession = nil;
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    [locationManager release];
    [compassImageView release];
    
    [currentLocation release];
    [sightLine release];
    [sightLineView release];
    [sightedPoint release];
    [distanceOptions release];
    [distanceUnit release];
    [objectToSet release];
    
    [super dealloc];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
        if(self.captureSession == nil)
            [self startCameraPreview];
        [captureSession startRunning];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults boolForKey:@"point_sighting_help_shown"]){
            [defaults setBool:YES forKey:@"point_sighting_help_shown"];
            //helpImageView.hidden = NO;
            //helpCloseButton.hidden = NO;
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Can't sight a point without a camera." 
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        //[self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if([CLLocationManager headingAvailable]){
        if(locationManager == nil){
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.headingFilter = 1.0;
            [locationManager startUpdatingHeading];
            [locationManager startUpdatingLocation];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This feature will not work on your device." 
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        //[self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UIAccelerometer *acceleromter = [UIAccelerometer sharedAccelerometer];
	acceleromter.delegate = self;
	acceleromter.updateInterval = updateFrequency;
    
    hold = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    errorLabel.hidden = YES;
    if(self.showLocationInfo)
        self.locationInfoView.hidden = NO;
    else
        self.locationInfoView.hidden = YES;
    
    if(self.distanceOptions == nil){
        NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:100];
        NSInteger number = 0;
        [numbers addObject:[NSNumber numberWithInt:number]];
        for(int i = 0; i<100; i++){
            if(number < 200)
                number += 10;
            else if(number < 1000)
                number += 50;
            else
                number += 100;
            
            [numbers addObject:[NSNumber numberWithInt:number]];
        }
        self.distanceOptions = numbers;
    }
    
    if(self.distanceUnit == nil)
        self.distanceUnit = @"M";
    
    self.distancePickerUnitLabel.text = self.distanceUnit;
    
    if(self.showSightedElevation){
        self.sightedElevationLabel.text = @"";
        self.sightedElevationLabel.hidden = NO;
        self.sightedElevationLabelLabel.hidden = NO;
    }else{
        self.sightedElevationLabel.hidden = YES;
        self.sightedElevationLabelLabel.hidden = YES;
    }
    [super viewWillAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    UIAccelerometer *acceleromter = [UIAccelerometer sharedAccelerometer];
	acceleromter.delegate = nil;

    [super viewDidDisappear:animated];
}

#pragma mark - Image preview
-(void)startCameraPreview{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
    self.captureSession = session;
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
	captureVideoPreviewLayer.frame = self.cameraView.frame;//self.backgroundView.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.cameraView.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
        self.captureSession = nil;
        [session release];
        [captureVideoPreviewLayer release];
        return;
	}
	[session addInput:input];
    
	[session startRunning];
    
    self.redLine = [UIImage imageNamed:@"horizon line red.png"];
    self.yellowLine = [UIImage imageNamed:@"horizon line yellow.png"];
    self.greenLine = [UIImage imageNamed:@"horizon line green.png"];
    
    [session release];
    [captureVideoPreviewLayer release];
}
-(void)stopCameraPreview{
    if(self.captureSession == nil)
        return;
    
    [captureSession stopRunning];
}

#pragma mark - picker view
-(int)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return distanceOptions.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[distanceOptions objectAtIndex:row] stringValue];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    distance = [[distanceOptions objectAtIndex:row] floatValue];
    [self updateSightedPoint];
    [self zoomToLocation:self.currentLocation];
}
#pragma mark - Responding to accelerations
// UIAccelerometer delegate method, which delivers the latest acceleration data.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(hold)
        return;
    
    // Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
    float accelerationX = acceleration.x * kFilteringFactor + acceleration.x * (1.0 - kFilteringFactor);
    float accelerationY = acceleration.y * kFilteringFactor + acceleration.y * (1.0 - kFilteringFactor);
    float accelerationZ = acceleration.z * kFilteringFactor + acceleration.z * (1.0 - kFilteringFactor);
	
    //elevation angle
    if(self.showSightedElevation){
        CGFloat currentRawReading = atan2(accelerationY, accelerationZ);
        CGFloat degrees = [self radiansToDegrees:currentRawReading];
        float calibratedDegrees = [self calibratedAngleFromAngle:degrees];
        self.lastAngleFloat = currentAngleFloat;
        calibratedDegrees = calibratedDegrees + 90;
        self.currentAngleFloat = calibratedDegrees;
        
        if(fabsf( currentAngleFloat - lastAngleFloat) > 0.5 ){//dont update unless angle changes
            [self calculateSightedElevation];
        }
    }
    
    //horizon angle
    CGFloat horizonAngle = [self radiansToDegrees:atan2(accelerationY, accelerationX)];
    if(currentHorizonAngle != horizonAngle){
        currentHorizonAngle = horizonAngle;
        horizonAngle += 90;
        if(fabs(horizonAngle) <= 5){
            horizonLineImage.image = greenLine;
            tilted = NO;
        }else if(fabs(horizonAngle) <= 10){
            horizonLineImage.image = yellowLine;
            tilted = NO;
        }else{
            horizonLineImage.image = redLine;
            tilted = YES;
        }
        horizonLineImage.transform = CGAffineTransformMakeRotation(-[self degreesToRadians:horizonAngle]);
        if(tilted){
            self.errorLabel.text = @"Please hold your device in a more upright position.";
            self.errorLabel.hidden = NO;
            if(showLocationInfo)
                self.locationInfoView.hidden = YES;
            [self removeSightFromMap];
        }else{
            self.errorLabel.hidden = YES;
            if(showLocationInfo)
                self.locationInfoView.hidden = NO;
        }
    }
	//label2.text = [[NSString alloc] initWithFormat:@"x:%1.1f  y:%1.1f  z:%1.1f ", acceleration.x, acceleration.y, acceleration.z];
}
-(CGFloat)radiansToDegrees:(CGFloat)radians{
	return radians * 180/M_PI;
}
-(CGFloat)degreesToRadians:(CGFloat)degrees{
	return degrees * (M_PI/180);
}
-(CGFloat)calibratedAngleFromAngle:(CGFloat)angle{
    //used stored calibration factor
    //works in degrees
	return angle;
}
-(void)calculateSightedElevation{
//    NSLog(@"vertical accuracy %1.0f, elevation %1.0f", currentLocation.verticalAccuracy, currentLocation.altitude);
    if(!self.currentLocation || self.currentLocation.verticalAccuracy > 100 || isnan(distance) || distance < 1.0)
        return;
    
    //do all the calculations in metric
    CLLocationDistance sightDistance = distance;
    if([self.distanceUnit isEqualToString:@"F"])
       sightDistance = [[unitConversion metersFromFeet:[NSNumber numberWithFloat:sightDistance]] floatValue];
    
    CGFloat angle = fabsf(currentAngleFloat);
    CLLocationDistance newElevation = tan(degreesToRadians(angle)) * sightDistance;
    //NSLog(@"distance: %f, elevation angle:%1.1f, tan=%1.1f, angle calculation: %1.1f", distance, angle, tan(degreesToRadians(angle)), newElevation);

    if (currentAngleFloat > 0)
        newElevation += self.currentLocation.altitude;
    else
        newElevation = self.currentLocation.altitude - newElevation;
    
    if([self.distanceUnit isEqualToString:@"F"])
        newElevation = [[unitConversion feetFromMeters:[NSNumber numberWithFloat:newElevation]] floatValue];
    
    self.sightedElevation = newElevation;    
    self.sightedElevationLabel.text = [NSString stringWithFormat:@"%1.0f %@", sightedElevation, distanceUnit];
}
#pragma mark - location delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    if(hold || tilted)
        return;
    
    CGFloat heading = [newHeading trueHeading];
    errorLabel.text = @"";
    if(isnan(heading)){
        heading = [newHeading magneticHeading];
        errorLabel.text = @"GPS location not available.  Direction not corrected for declination";
    }
    if(isnan(heading)){
        currentHeading = -1;
        errorLabel.text = @"Could not determine heading.";
        self.currentHeadingLabel.text = @"";
        return;
    }
    
    CGFloat difference = fabsf(currentAngleFloat - heading);
    if(difference > 2){
        compassImageView.transform = CGAffineTransformMakeRotation(-[self degreesToRadians:heading]);
        
        mapView.transform = CGAffineTransformMakeRotation(-[self degreesToRadians:heading]);
        self.currentHeadingLabel.text = [self convertDegreesToDirection:heading];
        self.currentHeading = heading;
        [self updateSightedPoint];

        for (id<MKAnnotation> annotation in mapView.annotations) {
            MKAnnotationView* annotationView = [mapView viewForAnnotation:annotation];
            annotationView.transform =  CGAffineTransformMakeRotation([self degreesToRadians:heading]);
            //[annotationView setTransform:CGAffineTransformMakeRotation(-heading)];
        }//this left the pin spinning wildly
        
    }
}
-(NSString *)convertDegreesToDirection:(CGFloat)degrees{
    return [unitConversion aspectStringFromDegrees:[NSNumber numberWithFloat:degrees]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    if(!hold && ![self CLLocationCoordinate2DEquals:self.currentLocation.coordinate 
                                    withSecondCoordinate:newLocation.coordinate] ){
        //[self.activityIndicator stopAnimating];
        [self zoomToLocation:newLocation];
        self.currentLocation = newLocation;
        
        //self.latLonLabel.text = [NSString stringWithFormat:@"%1.5f, %1.5f", currentLocation.coordinate.latitude, 
          //                       currentLocation.coordinate.longitude];
        
        
        if(currentLocation.verticalAccuracy > 0 && self.showLocationInfo){
            double currentEl = currentLocation.altitude;
            double accuracy = currentLocation.verticalAccuracy;
            if([distanceUnit isEqualToString:@"F"]){
                currentEl = [[unitConversion feetFromMeters:[NSNumber numberWithDouble:currentEl]] doubleValue];
                accuracy = [[unitConversion feetFromMeters:[NSNumber numberWithDouble:accuracy]] doubleValue];
            }
            self.myElevationLabel.text = [NSString stringWithFormat:@"%1.0f %@", currentEl, distanceUnit];
            self.myElevationAccuracyLabel.text = [NSString stringWithFormat:@"%1.0f %@", accuracy, distanceUnit];
        }
        [self updateSightedPoint];
        //NSLog(@"vertical accuracy %1.0f, elevation %1.0f", currentLocation.altitude, currentLocation.verticalAccuracy);
        //NSLog(@"updated current location, %1.6f %1.6f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    }
}
-(void)zoomToLocation:(CLLocation *)newLocation{
    CLLocationDistance regionDistance = distance * 4;
    if([distanceUnit isEqualToString:@"F"])
        regionDistance = [[unitConversion metersFromFeet:[NSNumber numberWithFloat:regionDistance]] floatValue];
    if(regionDistance < 1000)
        regionDistance = 1000;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionDistance * 1.4, regionDistance);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];                
    [self.mapView setRegion:adjustedRegion animated:YES]; 
}

- (BOOL) CLLocationCoordinate2DEquals:(const CLLocationCoordinate2D)lhs withSecondCoordinate:(const CLLocationCoordinate2D)rhs{
    const CLLocationDegrees DELTA = 0.0001;
    return fabs(lhs.latitude - rhs.latitude) <= DELTA && fabs(lhs.longitude - rhs.longitude) <= DELTA;
}

#pragma mark - 
-(void)updateSightedPoint{
    if(tilted)
        return;
    
    if(!isnan(distance) && distance > 1 && !isnan(currentHeading) && currentLocation){
        //NSLog(@"Updating sighted point, heading:%1.0f, distance:%1.0f", currentHeading, distance);
        CLLocationDistance measureDistance = distance;
        if([self.distanceUnit isEqualToString:@"F"]){
            measureDistance =  [[unitConversion metersFromFeet:[NSNumber numberWithFloat:measureDistance]] floatValue];
        }
        self.sightedCoordinate = [self destinationCoordinateOnRhumbLineUsingBearing:currentHeading
                                                                        andDistance:measureDistance 
                                                                          fromPoint:currentLocation.coordinate];
        self.sightedLatLonLabel.text = [NSString stringWithFormat:@"%1.5f, %1.5f", 
                                        sightedCoordinate.latitude, sightedCoordinate.longitude];
        
        [self drawSightLine];
        [self drawSightedPoint];
        //NSLog(@"current location: %1.5f, %1.5f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        //NSLog(@"sighted location: %1.5f, %1.5f", sightedCoordinate.latitude, sightedCoordinate.longitude);
    }else{
        //not enough data
    }
    
}

-(void)drawSightLine{
    CLLocationCoordinate2D linePoints[2];
    linePoints[0] = currentLocation.coordinate;
    linePoints[1] = sightedCoordinate;
    MKPolyline *newLine = [MKPolyline polylineWithCoordinates:linePoints count:2];
    [mapView addOverlay:newLine];
    
    if(self.sightLine != nil)
        [mapView removeOverlay:self.sightLine];
    
    self.sightLine = newLine;
}


-(void)drawSightedPoint{
    if(sightedPoint == nil){
        sightedPoint = [[mapPoint alloc] init];
        sightedPoint.coordinate = sightedCoordinate;
    }else{
        sightedPoint.coordinate = sightedCoordinate;
    }
    if( ![self.mapView.annotations containsObject:sightedPoint])
        [mapView addAnnotation:sightedPoint];
}
-(void)removeSightFromMap{
    if([mapView.annotations containsObject:sightedPoint])
        [mapView removeAnnotation:sightedPoint];
    if([mapView.overlays containsObject:sightLine])
        [mapView removeOverlay:sightLine];
}
- (CLLocationCoordinate2D)destinationCoordinateOnRhumbLineUsingBearing:(CLLocationDirection)bearing
                                                              andDistance:(CLLocationDistance)distanceToPoint 
                                                                fromPoint:(CLLocationCoordinate2D)startingCoord{
    double lat1 = degreesToRadians(startingCoord.latitude);
    double lon1 = degreesToRadians(startingCoord.longitude);
    double brng = degreesToRadians(bearing);
    double d = distanceToPoint;
    double R = EARTH_RADIUS;
    double lat2 = lat1 + (d / R) * cos(brng);
    double dLat = lat2 - lat1;
    double dPhi = log(tan(lat2 / 2 + M_PI_4) / tan(lat1 / 2 + M_PI_4));
    double q = (!isnan(dLat / dPhi) && !isinf(dLat / dPhi)) ? dLat / dPhi : cos(lat1);
    double dLon = (d / R) * sin(brng) / q;
    
    if (abs(lat2) > M_PI_2) {
        lat2 = (lat2 > 0) ? M_PI - lat2 : -(M_PI - lat2);
    }
    double lon2 = fmod((lon1 + dLon + 3 * M_PI), 2.0 * M_PI) - M_PI;
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(radiansToDegrees(lat2), radiansToDegrees(lon2));
    
    return destination;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    MKOverlayView* overlayView = nil;
    
    if([overlay isKindOfClass:[MKPolyline class]]){
        self.sightLineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
        self.sightLineView.fillColor = [UIColor redColor];
        self.sightLineView.strokeColor = [UIColor redColor];
        self.sightLineView.lineWidth = 3;
        overlayView = self.sightLineView;
    }
    
    return overlayView;
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *reuseIdentifier = @"sighted point";
    if(annotation == self.sightedPoint){
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if(annotationView == nil){
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.draggable = YES;
        }
        annotationView.annotation = annotation;
        return annotationView;

    }else if([annotation isKindOfClass:[MKUserLocation class]]){
        ((MKUserLocation *)annotation).title = @"";
        return nil;  //return nil to use default blue dot view
    }
    return nil;
}
#pragma mark - user interaction
- (IBAction)lockButtonPressed:(id)sender {
    if (hold) {
        hold = NO;
        [captureSession startRunning];
        [self.lockButton setImage: [UIImage imageNamed:@"lock wide unlocked.png"] forState:UIControlStateNormal];
    }else {
        hold = YES;
        [captureSession stopRunning];
        [self.lockButton setImage: [UIImage imageNamed:@"lock wide.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)saveButtonPressed {
    if(self.objectToSet){
        if([self.objectToSet respondsToSelector:@selector(setLatitude:)]){
            [objectToSet setValue:[NSNumber numberWithFloat:self.sightedCoordinate.latitude ] forKey:@"latitude"];
        }
        if([self.objectToSet respondsToSelector:@selector(setLongitude:)]){
            [objectToSet setValue:[NSNumber numberWithFloat:self.sightedCoordinate.latitude ] forKey:@"longitude"];
        }
        if([self.objectToSet respondsToSelector:@selector(setElevation:)]){
            [objectToSet setValue:[NSNumber numberWithFloat:self.sightedElevation ] forKey:@"elevation"];
        }
    }
}
@end
