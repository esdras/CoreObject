#import <CoreObject/CoreObject.h>

@interface Tag : COGroup

@property (readwrite, retain, nonatomic) NSString *label;
@property (readwrite, retain, nonatomic) NSSet *contents;

@end