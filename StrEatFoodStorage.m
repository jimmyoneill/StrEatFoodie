//
//  StrEatFoodStorage.m
//  StrEatFoodie
//
//  Created by James O'Neill on 12/8/12.
//
//

#import "StrEatFoodStorage.h"

@interface StrEatFoodStorage ()

@property (nonatomic) NSMutableArray *trucks;
@property (nonatomic, readonly) NSString *filePath;

@end

@implementation StrEatFoodStorage

@synthesize trucks = _trucks;
@synthesize filePath = _filePath;

+ (StrEatFoodStorage *)sharedStorage
{
    static dispatch_once_t once;
    static StrEatFoodStorage *sharedStorage;
    dispatch_once(&once, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self ensureTruckWhitelist];
    }
    return self;
}

- (void)addTruck:(NSString *)truckName
{
    if (![self.trucks containsObject:truckName]) {
        [self.trucks addObject:truckName];
        [self.trucks writeToFile:self.filePath atomically:YES];
    }
}

- (void)addTrucks:(NSArray *)truckNames
{
    for (NSString *truckName in truckNames) {
        [self addTruck:truckName];
    }
}

- (NSString *)filePath
{
    if (!_filePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"foodTruckWhitelist"];
        _filePath = filePath;
    }
    return _filePath;
}

- (void)ensureTruckWhitelist
{
    NSMutableArray *trucks = [[NSMutableArray alloc] initWithContentsOfFile:self.filePath];
    if (!trucks) {
        // This is the seed whitelist of trucks. When new trucks are mentioned, they will be added to this whitelist.
        trucks = [[NSMutableArray alloc] initWithObjects:
                  @"BaoandBowl", @"slidershacksf", @"mannajpt", @"adamsgrubtruck", @"gyrosonwheels1",
                  @"LaPastrami", @"CookieTimeTruck", @"TheWaffleMobile", @"Sanguchon_SF", @"babalootruck",
                  @"MeSoHungrySF", @"LetsEatGrilStop", @"TacosElTuca", @"EireTrea", @"SmokinWarehouse",
                  @"CurryUpNow", @"lilgreencyclo", @"seoulonwheels", @"HongryKong", @"EatFuki", @"Elevasiansf",
                  @"StreetDogTruck", @"Brassknucklesf", @"FishTankTruck", @"pizzadelpopolo", @"KoJaKitchen",
                  @"KasaIndian", @"TheRibWhip", @"elsursf", @"MrNiceSF",
                  nil];

        [trucks writeToFile:self.filePath atomically:YES];
    }
    self.trucks = trucks;
}

@end
