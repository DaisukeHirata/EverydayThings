#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Item;

@interface MapViewController : UIViewController

@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) Item* item;

@end
