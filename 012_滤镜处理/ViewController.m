//
//  ViewController.m
//  012_滤镜处理
//
//  Created by zsq on 2020/8/9.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "ViewController.h"
#import "FilterBar.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord; //(x,y,z)
    GLKVector2 textureCoord;  // (U, V)
} SenceVertex;

@interface ViewController ()<FilterBarDelegate>

@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint textureID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建滤镜工具栏
    [self setupFilterBar];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

// 创建滤镜栏
- (void)setupFilterBar {
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 100;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight;
    FilterBar *filerBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filerBar.delegate = self;
    [self.view addSubview:filerBar];
    
    NSArray *dataSource = @[@"无",@"分屏_2",@"分屏_3",@"分屏_4",@"分屏_6",@"分屏_9"];
    filerBar.itemList = dataSource;
}
#pragma mark - 从图片中加载纹理
- (GLuint)createTextureWithImage:(UIImage *)image {
    //1、将 UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
}

- (void)dealloc{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

@end
