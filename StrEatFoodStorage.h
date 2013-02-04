//
//  StrEatFoodStorage.h
//  StrEatFoodie
//
//  Created by James O'Neill on 12/8/12.
//
//

#import <Foundation/Foundation.h>

@interface StrEatFoodStorage : NSObject

+ (StrEatFoodStorage *)sharedStorage;

- (void)addTruck:(NSString *)truckName;
- (void)addTrucks:(NSArray *)truckNames;

@property (nonatomic, readonly) NSMutableArray *trucks;

@end
