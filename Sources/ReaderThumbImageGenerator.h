//
//  ReaderThumbImageGenerator.h
//  Pods
//
//  Created by Patrick Nollet on 27/08/2015.
//
//

#import "ReaderThumbRequest.h"

@interface ReaderThumbImageGenerator : NSObject
+ (UIImage *)imageForRequest:(ReaderThumbRequest *)request;
@end
