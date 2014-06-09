//
//  MainViewController.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 13..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "MainViewController.h"
#import "Pin.h"
#import "BusinessUtil.h"
#import "SearchView.h"
#import <NSString+CJStringValidator.h>
@interface MainViewController ()
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UIView* localtionDetailView;
@property (nonatomic, weak) IBOutlet UILabel* locationNameLabel;
@property (nonatomic, weak) IBOutlet UIView* bannerView;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *bannerBtnArray;

@property (nonatomic, strong) Pin* pin;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableSet* localSet;
@property (nonatomic, strong) NSMutableArray* bannerArray;
@end


@implementation MainViewController
static int kRefreshDistance = 100; // 몇미터 이동해야 리프레쉬 할거냐
static int kLoadDistanceDelta = 2.0f; // 얼마나 스케일이 축소되야 정보를 가져올 거냐
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    [_mapView setMapType:MKMapTypeStandard];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(50, 0);
    [_mapView showsUserLocation];
    */
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [_locationManager startUpdatingLocation];
    
    _geocoder = [[CLGeocoder alloc] init];
    _localCode = @"";
    _localSet = [NSMutableSet new];
}
- (IBAction)currentLocationClick:(id)sender{
    [self reloadMap];
}

- (IBAction)searchClick:(id)sender{
    SearchView* searchView =  [[[NSBundle mainBundle] loadNibNamed:@"SearchView" owner:nil options:nil] objectAtIndex:0];
    //searchView.backgroundColorView.backgroundColor = [UIColor clearColor];
    searchView.mainViewCont = self;
    [searchView initView];
    [self.view addSubview:searchView];
    searchView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        searchView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        //searchView.backgroundColorView.backgroundColor = [UIColor blackColor];
    }];
}

- (IBAction)detailClick:(id)sender
{
    
}

- (IBAction)phoneClick:(id)sender
{
    if (_pin) {
        if ([_pin.phoneNumber isPhoneNumber]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_pin.phoneNumber]]];
        }
    }
}

- (IBAction)bannerClick:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    JY_LOG(@"BNNER CLICK :%d",tag);
}

- (void)reloadMap{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = _location.coordinate.latitude;
    zoomLocation.longitude= _location.coordinate.longitude;
    
    CLLocationDistance mapSizeMeters = 1000;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, mapSizeMeters, mapSizeMeters);
    
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    if(adjustedRegion.center.longitude != -180.00000000){
        if (isnan(adjustedRegion.center.latitude)) {
            adjustedRegion.center.latitude = viewRegion.center.latitude;
            adjustedRegion.center.longitude = viewRegion.center.longitude;
            adjustedRegion.span.latitudeDelta = 0;
            adjustedRegion.span.longitudeDelta = 0;
        }
        
        
        [_mapView setRegion:adjustedRegion animated:YES];
    }
}
- (void)getNearInnList:(NSString*)address{
    JY_LOG(@"getNearInnList : %ld",[[AFAppDotNetAPIClient sharedClient].operationQueue.operations count]);
    // 통신 중이면 다시 가져오지 않음
    if ([[AFAppDotNetAPIClient sharedClient].operationQueue.operations count] >= 1) {
        return ;
    }
    
    // 현재와 같은 localCode 가져올려고 하면
    if ([_localCode isEqualToString:[BusinessUtil localCodeFromAddress:address]]) {
        return ;
    }
    // 이미 가져온 localCode 이면 가져오지 않음
    if ([_localSet containsObject:[BusinessUtil localCodeFromAddress:address]]) {
        return ;
    }
    _localCode = [BusinessUtil localCodeFromAddress:address];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:_localCode forKey:@"locCode"];
    
    [[AFAppDotNetAPIClient sharedClient].operationQueue cancelAllOperations];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"MakeEndAppList.asp" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        NSDictionary* dic = [NSDictionary dictionaryWithXMLData:responseObject];
#ifdef __DEBUG_LOG__
        //JY_LOG(@"MakeEndAppList.asp: %@",[[XMLDictionaryParser sharedInstance] dictionaryWithData:responseObject]);
        JY_LOG(@"MakeEndAppList.asp: %@",[dic objectForKey:@"member"]);
#endif
        
        // TODO : 가장 가까운 숙소위치로 맵 스케일 변경
        for (NSDictionary* member in [dic objectForKey:@"member"]) {
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[member objectForKey:@"locationlat"] doubleValue], [[member objectForKey:@"locationlng"] doubleValue]);
            Pin* pin = [[Pin alloc] initWithCoordinates:location withData:@{@"title": [member objectForKey:@"name"],
                                                                            @"phoneNumber": [member objectForKey:@"phone"]}];
            [_mapView addAnnotation:pin];
        }
        [_localSet addObject:_localCode];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndAppList.asp [HTTPClient Error]: %@", error.localizedDescription);
#endif
        FSAlertView *alert = [[FSAlertView alloc] initWithTitle:@"MakeEnd" message:@"서버에 연결할 수 없습니다." cancelButton:[FSBlockButton blockButtonWithTitle:@"확인" block:^ {
            
        }] otherButtons: nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
- (void)reverseGeocoder:(CLLocation*)location{
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark* placemark = [placemarks lastObject];
            if (placemark.administrativeArea == NULL || placemark.locality == NULL || placemark.locality == placemark.thoroughfare) {
                _addressLabel.text = @"주소를 가져올 수 없습니다.";
            }else{
                _addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@",placemark.administrativeArea, placemark.locality, placemark.thoroughfare];
            }
            // local 코드가 다를때만
            if (![_localCode isEqualToString:[BusinessUtil localCodeFromAddress:placemark.administrativeArea]]) {
                [self getNearInnList:placemark.administrativeArea];
            }
        } else {
            _addressLabel.text = @"위치를 가져올수 없습니다.";
        }
    } ];
}

- (void)postMyLocation{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"appid" forKey:@"app_id"];
    [parameters setObject:[NSString stringWithFormat:@"%lf",_location.coordinate.latitude] forKey:@"lat"];
    [parameters setObject:[NSString stringWithFormat:@"%lf",_location.coordinate.longitude] forKey:@"lng"];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"MakeEndAppAdd.asp" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        NSDictionary* dic = [NSDictionary dictionaryWithXMLData:responseObject];
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndAppAdd.asp: %@",[dic objectForKey:@"resultcode"]);
#endif
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndAppAdd.asp [HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
}

- (void)setBannerView{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:_localCode forKey:@"locCode"];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"MakeEndBannerList.asp" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        NSDictionary* dic = [NSDictionary dictionaryWithXMLData:responseObject];
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndBannerList.asp: %@",[dic objectForKey:@"bannerlist"]);
#endif
        _bannerArray = [dic objectForKey:@"bannerlist"];
        int idx = 0;
        for (UIButton* btn in _bannerBtnArray) {
            if (idx < [_bannerArray count]) {
                [btn setTag:idx];
                [btn setTitle:[[_bannerArray objectAtIndex:idx] objectForKey:@"bannertitle"] forState:UIControlStateNormal];
            }
            idx++;
        }
        
        _bannerView.hidden = FALSE;
        _bannerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            _bannerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
            //searchView.backgroundColorView.backgroundColor = [UIColor blackColor];
        }];
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndQuickList.asp [HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation != NULL) {
        //_location = newLocation;
        //JY_LOG(@"locationManager : %lf , %lf",_location.coordinate.latitude,_location.coordinate.longitude);
        //[self reloadMap];
    }
}
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations{
    CLLocation* location = [locations lastObject];
    
    if (location != NULL) {
        if (_location == NULL || [location distanceFromLocation:_location] > kRefreshDistance) {
            _location = location;
            JY_LOG(@"locationManager : %lf , %lf",_location.coordinate.latitude,_location.coordinate.longitude);
            [self reloadMap];
            [self reverseGeocoder:_location];
            [self postMyLocation];
            [self setBannerView];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    JY_LOG(@"didFailWithError : %@",error);
    _addressLabel.text = @"위치를 가져올수 없습니다.";
    /*
    FSAlertView *alert = [[FSAlertView alloc] initWithTitle:@"MakeEnd" message:@"위치정보를 가져올 수 없습니다." cancelButton: [FSBlockButton blockButtonWithTitle:@"확인" block:^ {
        
    }]otherButtons:nil];
    [alert show];
     */
}
#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    JY_LOG(@"regionWillChangeAnimated");
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    JY_LOG(@"regionDidChangeAnimated : %lf %lf %lf %lf",mapView.region.center.latitude,mapView.region.center.longitude,mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
    // 너무 큰맵이면 리로드 하지 않는다.
    if (mapView.region.span.latitudeDelta < kLoadDistanceDelta && mapView.region.span.longitudeDelta < kLoadDistanceDelta) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
        [self reverseGeocoder:location];
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Pin";
    if ([annotation isKindOfClass:[Pin class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            Pin* pin = annotation;
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            /*
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            if ([pin.phoneNumber isPhoneNumber]) {
                //annotationView.rightCalloutAccessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ballon_call.png"]];
                [rightButton setImage:[UIImage imageNamed:@"ballon_call.png"] forState:UIControlStateNormal];
            }else{
                //annotationView.rightCalloutAccessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ballon_call_on.png"]];
                [rightButton setImage:[UIImage imageNamed:@"ballon_call_on.png"] forState:UIControlStateNormal];
            }
            [rightButton setTitle:@"" forState:UIControlStateNormal];
            [annotationView setRightCalloutAccessoryView:rightButton];
             */
            annotationView.image = [UIImage imageNamed:@"empty_room_marker_on.png"];
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

- (void)annotationClick:(UITapGestureRecognizer *)gestureRecognizer
{
   }

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    /*
    Pin* pin = view.annotation;
    if ([pin.phoneNumber isPhoneNumber]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",pin.phoneNumber]]];
    }
     */
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    JY_LOG(@"didSelectAnnotationView");
    _pin = view.annotation;
    _locationNameLabel.text = _pin.title;
    _localtionDetailView.hidden = FALSE;
    _localtionDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        _localtionDetailView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    JY_LOG(@"didDeselectAnnotationView");
    _pin = NULL;
    _locationNameLabel.text = @"";
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        _localtionDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
