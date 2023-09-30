#import <Foundation/Foundation.h>

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSMutableURLRequest *)request 
                            completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    NSURL *url = request.URL;
    // GraphQL requests are sent to https://m-api01.verisure.com/graphql, https://m-api02.verisure.com/graphql or similar.
    if (![url.host hasSuffix:@"verisure.com"] || ![url.path isEqualToString:@"/graphql"]) {
        return %orig;
    }

    // Body must contain a clientVersionValidation query.
    NSData *body = request.HTTPBody;
    if (body.length < 40) {
        return %orig;
    }
    NSString *bodyPrefix = [NSString stringWithUTF8String:[body subdataWithRange:NSMakeRange(0, 40)].bytes];
    if (![bodyPrefix isEqualToString:@"[{\"query\":\"query clientVersionValidation"]) {
        return %orig;
    }

    // Respond with "VALID".
    void (^interceptedCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^void(NSData *responseObject, NSURLResponse *response, NSError *error) {
        NSDictionary *payload = @{
            @"data": @{
                @"clientVersionValidation": @{
                    @"versionStatus": @"VALID"
                }
            }
        };
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:kNilOptions error:&error];
        completionHandler(data, response, error);
    };
    return %orig(request, interceptedCompletionHandler);
}

%end
