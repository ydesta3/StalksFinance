//
//  APIManager.m
//  StalkFinance
//
//  Created by Yonatan Desta on 7/7/22.
//

#import "APIManager.h"

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void) fetchStockQuote :(void(^)(NSArray *stocks, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:@"https://yfapi.net/ws/screeners/v1/finance/screener/predefined/saved?count=50&scrIds=day_gainers"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"APIKey"];
    [request addValue:key forHTTPHeaderField:@"X-API-KEY"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@": YD1: %@", [error localizedDescription]);
//               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Stock Info"
//                                              message:@"The Internet connection seems to be offline."
//                                              preferredStyle:UIAlertControllerStyleAlert];
//               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
//                                                                     handler:^(UIAlertAction * action) {[self fetchStockQuote];}];
//
//               [alert addAction:defaultAction];
            }
           else {
               NSDictionary *stockDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSDictionary *financeDictionary = stockDictionary[@"finance"];
               NSLog(@": YD2: %@", financeDictionary);
               NSDictionary *result = financeDictionary[@"result"];
               NSLog(@"stockResults: %@", result);
               NSMutableArray *quotes = nil;
               for (NSDictionary *dict in result) {
                   quotes = dict[@"quotes"];
                   //NSLog(@"stockQuotes: %@", quotes);
               }
               NSLog(@"stockQuotes: %@", quotes);
               NSMutableArray *stocks = [Stock arrayOfStocks:quotes];
               completion(stocks, nil);
           }
       }];
    [task resume];
}


@end
