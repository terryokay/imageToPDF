//
//  ViewController.m
//  imageToPDF
//
//  Created by apple on 2019/10/10.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@property(nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //需要将保存的Image是图保存 到本地相册
    [self saveImage:[UIImage imageNamed:@""]];
    
}
#pragma mark - 保存UIImage到本地相册
- (void)saveImage:(UIImage *)image{
    
    self.library = [[ALAssetsLibrary alloc]init];
    [self.library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [self turnSelfViewToPDFWithAssetUrl:assetURL];
        
    }];
}

- (void)turnSelfViewToPDFWithAssetUrl:(NSURL *)url{
        
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullScreenImage];
        if (iref) {
            UIImage *image = [UIImage imageWithCGImage:iref];
            [self setupPDFDocumentNamed:@"123" width:100 height:100];
            [self addImage:image atPoint:CGPointMake(0, 0)];
        }
        
        
    } failureBlock:^(NSError *error) {
       NSLog(@"从图库获取图片失败: %@",error);
    }];
}
#pragma mark - 设置PDF名称 与 宽高尺寸
- (void)setupPDFDocumentNamed:(NSString*)name width:(float)width height:(float)height {
    CGSize _pageSize = CGSizeMake(width, height);
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf",name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);
}
#pragma mark - 添加UIImage 到 PDF 的 CGPoint上
- (void)addImage:(UIImage*)image atPoint:(CGPoint)point {
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
     UIGraphicsEndPDFContext();
}
//添加（绘制）文字
- (CGRect)addText:(NSString*)text withFrame:(CGRect)frame fontSize:(float)fontSize {
    CGSize _pageSize = CGSizeMake(0, 0);//配置大小
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *style1 = [NSMutableParagraphStyle new];
    style1.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize stringSize = [text boundingRectWithSize:_pageSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSParagraphStyleAttributeName:style1} context:nil].size;
    
    float textWidth = frame.size.width;
    
    if (textWidth < stringSize.width)
        textWidth = stringSize.width;
    if (textWidth > _pageSize.width)
        textWidth = _pageSize.width - frame.origin.x;
    CGRect renderingRect = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;

    [text drawInRect:renderingRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:style,NSBackgroundColorAttributeName:[UIColor whiteColor]}];
    frame = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    return frame;
}
//添加（绘制） 线
-  (CGRect)addLineWithFrame:(CGRect)frame withColor:(UIColor*)color {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    CGContextSetLineWidth(currentContext, frame.size.height);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    return frame;
}















#pragma mark - 长度超过一个屏幕的View，通常是scrollView 转成image长图片
- (UIImage *)snapShotWithScrollView:(UIScrollView *)scrollView{
    UIImage *image = nil;
    
    UIGraphicsBeginImageContext(scrollView.contentSize);
    
    CGPoint savedContentOffset = scrollView.contentOffset;
    CGRect savedFrame = scrollView.frame;
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    scrollView.contentOffset = savedContentOffset;
    scrollView.frame = savedFrame;
    
    UIGraphicsEndImageContext();
    
    
    
    
    return image;
}


#pragma mark - 长度不超过一个屏幕的View生成图片
- (UIImage *)snapShotWithView:(UIView *)view{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}


@end
