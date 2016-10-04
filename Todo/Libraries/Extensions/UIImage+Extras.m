#import "UIImage+Extras.h"

@implementation UIImage (Extras)

#pragma mark - Color

+ (UIImage *)imageFromColor:(UIColor *)color;
{
    CGRect rect = (CGRect){0, 0, 1, 1};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)resize:(CGSize)size;
{
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [self drawInRect:(CGRect){0, 0, size.width, size.height}];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image imageWithRenderingMode:[self renderingMode]];
}

@end
