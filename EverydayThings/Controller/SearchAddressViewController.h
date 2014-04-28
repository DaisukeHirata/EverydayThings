#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchAddressViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places;

@end
