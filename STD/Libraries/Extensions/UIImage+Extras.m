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

@end
