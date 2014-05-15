#import "SearchAddressViewController.h"
#import "MapViewController.h"

#import <MapKit/MapKit.h>

// note: we use a custom segue here in order to cache/reuse the
//       destination view controller (i.e. MapViewController) each time you select a place
//
@interface DetailSegue : UIStoryboardSegue
@end

@implementation DetailSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    SearchAddressViewController *sourceViewController = self.sourceViewController;
    MapViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}

@end


#pragma mark -

static NSString *kCellIdentifier = @"cellIdentifier";

@interface SearchAddressViewController ()

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *viewAllButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;

@property (nonatomic, strong) DetailSegue *detailSegue;
@property (nonatomic, strong) DetailSegue *showAllSegue;
@property (nonatomic, strong) MapViewController *mapViewController;

- (IBAction)showAll:(id)sender;

@end


#pragma mark -

@implementation SearchAddressViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // start by locating user's current position
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
    
    // create and reuse for later the mapViewController
    self.mapViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"MapViewControllerID"];
    
    // use our custom segues to the destination view controller is reused
    self.detailSegue = [[DetailSegue alloc] initWithIdentifier:@"showDetail"
                                                              source:self
                                                         destination:self.mapViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    
	return cell;
}

- (IBAction)showAll:(id)sender
{
    // pass the new bounding region to the map destination view controller
    self.mapViewController.boundingRegion = self.boundingRegion;
    
    // pass the places list to the map destination view controller
    self.mapViewController.mapItemList = self.places;
    
    [self.showAllSegue perform];
}

- (IBAction)searchHere:(id)sender
{
    
    NSLog(@"user current position %f %f", self.userLocation.latitude, self.userLocation.longitude);
    CGFloat epsilon = 0.000001;
    if (self.userLocation.latitude < epsilon && self.userLocation.longitude < epsilon) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                        message:@"Could not retrieve location from your device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.userLocation.latitude
                                                      longitude:self.userLocation.longitude];
    
    CLGeocodeCompletionHandler completionHandler = ^(NSArray* placemarks, NSError* error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            // the result from reverse geocoding
            NSLog(@"found : %lu", (unsigned long)[placemarks count]);
            
            NSMutableArray *mapItems = [NSMutableArray array];
            for (CLPlacemark *clPlacemark in placemarks) {
                MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:clPlacemark];
                MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
                mapItem.name = clPlacemark.name;
                [mapItems addObject:mapItem];
            }
            
            self.places = mapItems;
            
            // used for later when setting the map's region in "prepareForSegue"
            //                       self.boundingRegion = response.boundingRegion;
            
            [self.tableView reloadData];
            
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"addressDictionary : %@", [placemark.addressDictionary description]);
                
                NSLog(@"name : %@", placemark.name);
                NSLog(@"thoroughfare : %@", placemark.thoroughfare);
                NSLog(@"subThoroughfare : %@", placemark.subThoroughfare);
                NSLog(@"locality : %@", placemark.locality);
                NSLog(@"subLocality : %@", placemark.subLocality);
                NSLog(@"administrativeArea : %@", placemark.administrativeArea);
                NSLog(@"subAdministrativeArea : %@", placemark.subAdministrativeArea);
                NSLog(@"postalCode : %@", placemark.postalCode);
                NSLog(@"ISOcountryCode : %@", placemark.ISOcountryCode);
                NSLog(@"country : %@", placemark.country);
                NSLog(@"inlandWater : %@", placemark.inlandWater);
                NSLog(@"ocean : %@", placemark.ocean);
                NSLog(@"areasOfInterest : %@", placemark.areasOfInterest);
            }

        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    [geocoder reverseGeocodeLocation:location completionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // pass the new bounding region to the map destination view controller
    self.mapViewController.boundingRegion = self.boundingRegion;
    
    // pass the individual place to our map destination view controller
    NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];
    self.mapViewController.mapItemList = [NSArray arrayWithObject:[self.places objectAtIndex:selectedItem.row]];
    
    [self.detailSegue perform];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userLocation.latitude;
    newRegion.center.longitude = self.userLocation.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.places = [response mapItems];
            
            // used for later when setting the map's region in "prepareForSegue"
            self.boundingRegion = response.boundingRegion;
            
            self.viewAllButton.enabled = self.places != nil ? YES : NO;
            
            [self.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    }
        
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
    
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                            message:alertMessage
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // remember for later the user's current location
    self.userLocation = newLocation.coordinate;
    NSLog(@"current position %f %f", self.userLocation.latitude, self.userLocation.longitude);
    
	[manager stopUpdatingLocation]; // we only want one update
    
    manager.delegate = nil;         // we might be called again here, even though we
                                    // called "stopUpdatingLocation", remove us as the delegate to be sure
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // report any errors returned back from Location Services
}

@end

