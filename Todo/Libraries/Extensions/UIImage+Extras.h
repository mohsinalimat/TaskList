@interface UIImage (Extras)

#pragma mark - Color

+ (UIImage *)imageFromColor:(UIColor *)color;
- (UIImage *)resize:(CGSize)size;

@end