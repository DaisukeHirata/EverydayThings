#import "MapViewController.h"
#import "PlaceAnnotation.h"

@interface MapViewController ()
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) PlaceAnnotation *annotation;
@end

@implementation MapViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // adjust the map to zoom/center to the annotations we want to show
    [self.mapView setRegion:self.boundingRegion];
    
    if (self.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];
        
        self.title = mapItem.name;
        
        // add the single annotation to our map
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        [self.mapView addAnnotation:annotation];
        
        // we have only one annotation, select it's callout
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
        self.mapView.centerCoordinate = mapItem.placemark.coordinate;
    }
    else
    {
        self.title = @"All Places";
        
        // add all the found annotations to the map
        for (MKMapItem *item in self.mapItemList)
        {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.url = item.url;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[PlaceAnnotation class]])
	{
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil)
		{
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			annotationView.canShowCallout = YES;
			annotationView.animatesDrop = YES;
		}
	}
	return annotationView;
}

@end
