//
//	ReaderThumbRender.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderThumbRender.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbImageGenerator.h"
#import "ReaderThumbView.h"

#import <ImageIO/ImageIO.h>

@implementation ReaderThumbRender
{
    ReaderThumbRequest *request;
    void (^completionBlock)(UIImage *);
}

#pragma mark - ReaderThumbRender instance methods

- (instancetype)initWithRequest:(ReaderThumbRequest *)options
{
    if ((self = [super initWithGUID:options.guid]))
    {
        request = options;
    }

    return self;
}

- (void)cancel
{
	[super cancel]; // Cancel the operation

	request.thumbView.operation = nil; // Break retain loop

	request.thumbView = nil; // Release target thumb view on cancel

	[[ReaderThumbCache sharedInstance] removeNullForKey:request.cacheKey];
}

- (NSURL *)thumbFileURL
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSString *cachePath = [ReaderThumbCache thumbCachePathForGUID:request.guid]; // Thumb cache path

	[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];

	NSString *fileName = [[NSString alloc] initWithFormat:@"%@.png", request.thumbName]; // Thumb file name

	return [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:fileName]]; // File URL
}

- (void)main
{
    UIImage *image = [ReaderThumbImageGenerator imageForRequest:request];
    [[ReaderThumbCache sharedInstance] setObject:image forKey:request.cacheKey]; // Update cache

    if (self.isCancelled == NO) // Show the image in the target thumb view on the main thread
    {
        ReaderThumbView *thumbView = request.thumbView; // Target thumb view for image show

        NSUInteger targetTag = request.targetTag; // Target reference tag for image show

        dispatch_async(dispatch_get_main_queue(), // Queue image show on main thread
                       ^{
                           if (thumbView.targetTag == targetTag) [thumbView showImage:image];
                       });
    }

    CFURLRef thumbURL = (__bridge CFURLRef)[self thumbFileURL]; // Thumb cache path with PNG file name URL

    CGImageDestinationRef thumbRef = CGImageDestinationCreateWithURL(thumbURL, (CFStringRef)@"public.png", 1, NULL);

    if (thumbRef != NULL) // Write the thumb image file out to the thumb cache directory
    {
        CGImageDestinationAddImage(thumbRef, image.CGImage, NULL); // Add the image

        CGImageDestinationFinalize(thumbRef); // Finalize the image file

        CFRelease(thumbRef); // Release CGImageDestination reference
    }

	else // No image - so remove the placeholder object from the cache
	{
		[[ReaderThumbCache sharedInstance] removeNullForKey:request.cacheKey];
	}

	request.thumbView.operation = nil; // Break retain loop
}

@end
