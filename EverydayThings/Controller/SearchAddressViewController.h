#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Item;

@interface SearchAddressViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) Item* item;

@end
