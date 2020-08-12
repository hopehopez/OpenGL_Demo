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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //创建滤镜工具栏
    [self setupFilterBar];
    
    //滤镜处理初始化
    [self filterInit];
    
    //开始一个滤镜动画
    [self startFilerAnimation];
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
    
    NSArray *dataSource = @[@"无",@"分屏_2",@"分屏_3",@"分屏_4",@"分屏_6",@"分屏_9",@"灰度",@"颠倒",@"马赛克",@"六边形马赛克",@"三角形马赛克"];
    filerBar.itemList = dataSource;
}

- (void)filterInit {
    //1. 初始化上下文并设置为当前上下文
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    //2.开辟顶点数组内存空间
    self.vertices = malloc(sizeof(SenceVertex)*4);
    
    //3.初始化顶点(0,1,2,3)的顶点坐标以及纹理坐标
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    //4.创建图层(CAEAGLLayer)
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
    layer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:layer];
    
    //5.绑定渲染缓冲区
    [self bindRenderLayer:layer];
    
    //6.获取处理的图片路径
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"natuo.jpg"];
    //读取图片
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //将JPG图片转换成纹理图片
    GLuint textureID = [self createTextureWithImage:image];
    //设置纹理ID
    self.textureID = textureID;  // 将纹理 ID 保存，方便后面切换滤镜的时候重用
    
    //7.设置视口
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    //8.设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex)*4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    //9.设置默认着色器
    [self setupNormalShaderProgram]; // 一开始选用默认的着色器
    
    //10.将顶点缓存保存，退出时才释放
    self.vertexBuffer = vertexBuffer;
}

#pragma mark - 绑定渲染缓冲区
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    //1.渲染缓存区,帧缓存区对象
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    //2.获取渲染缓存区名称,绑定渲染缓存区以及将渲染缓存区与layer建立连接
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    //3.获取帧缓存区名称,绑定帧缓存区以及将渲染缓存区附着到帧缓存区上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    //    //1.渲染缓存区,帧缓存区对象
    //       GLuint renderBuffer;
    //       GLuint frameBuffer;
    //
    //       //2.获取帧渲染缓存区名称,绑定渲染缓存区以及将渲染缓存区与layer建立连接
    //       glGenRenderbuffers(1, &renderBuffer);
    //       glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    //       [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    //
    //       //3.获取帧缓存区名称,绑定帧缓存区以及将渲染缓存区附着到帧缓存区上
    //       glGenFramebuffers(1, &frameBuffer);
    //       glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    //       glFramebufferRenderbuffer(GL_FRAMEBUFFER,
    //                                 GL_COLOR_ATTACHMENT0,
    //                                 GL_RENDERBUFFER,
    //                                 renderBuffer);
}

#pragma mark - 从图片中加载纹理
- (GLuint)createTextureWithImage:(UIImage *)image {
    //1、将 UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    //判断图片是否获取成功
    if (!cgImageRef) {
        NSLog(@"failed to load image");
        exit(1);
    }
    
    //2.读取图片的大小 宽高
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    //获取图片的rect
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //获取图片的颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //3.获取图片的字节数
    void *imageData = malloc(width*height*4);
    
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //5.将图片翻转过来(图片默认是倒置的)
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    //6.对图片进行重新绘制，得到一张新的解压缩后的位图
    CGContextDrawImage(context, rect, cgImageRef);
    
    //设置图片纹理属性
    //7. 获取纹理ID
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    //8.载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    //9.设置纹理属性
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //10.释放
    CGContextRelease(context);
    free(imageData);
    
    //11.返回纹理
    return textureID;
    
}
// 开始一个滤镜动画
- (void)startFilerAnimation {
    //1.判断displayLink 是否为空
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    //2. 设置displayLink 的方法
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    //3.将displayLink 添加到runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

//2. 动画
- (void)timeAction {
    //DisplayLink 的当前时间撮
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    //使用program
    glUseProgram(self.program);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "Time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark - FilterBarDelegate
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index {
    //1. 选择默认shader
    if (index == 0) {
        [self setupNormalShaderProgram];
    }else if(index == 1)
    {
        [self setupSplitScreen_2ShaderProgram];
    }else if(index == 2)
    {
        [self setupSplitScreen_3ShaderProgram];
    }else if(index == 3)
    {
        [self setupSplitScreen_4ShaderProgram];
    }else if(index == 4)
    {
        [self setupSplitScreen_6ShaderProgram];
    }else if(index == 5)
    {
        [self setupSplitScreen_9ShaderProgram];
    }else if (index == 6) {
        [self setupGrayShaderProgram];
    }else if(index == 7)
    {
        [self setupReversalShaderProgram];
    }else if (index == 8)
    {
        [self setupMosaicShaderProgram];
    }else if (index == 9)
    {
        [self setupHexagonMosaicShaderProgram];
    }else if (index == 10)
    {
        [self setupTriangularMosaicShaderProgram];
    }
    // 重新开始滤镜动画
//    [self startFilerAnimation];
}
#pragma mark - 选择 Shader
// 默认着色器程序
- (void)setupNormalShaderProgram {
    //设置着色器程序
    [self setupShaderProgramWithName:@"Normal"];
}

// 分屏(2屏)
- (void)setupSplitScreen_2ShaderProgram {
    [self setupShaderProgramWithName:@"SplitScreen_2"];
}

// 分屏(3屏)
- (void)setupSplitScreen_3ShaderProgram {
    [self setupShaderProgramWithName:@"SplitScreen_3"];
}

// 分屏(4屏)
- (void)setupSplitScreen_4ShaderProgram {
    [self setupShaderProgramWithName:@"SplitScreen_4"];
}

// 分屏(6屏)
- (void)setupSplitScreen_6ShaderProgram {
    [self setupShaderProgramWithName:@"SplitScreen_6"];
}

// 分屏(9屏)
- (void)setupSplitScreen_9ShaderProgram {
    [self setupShaderProgramWithName:@"SplitScreen_9"];
}

// 灰度滤镜着色器程序
- (void)setupGrayShaderProgram {
    //设置着色器程序
    [self setupShaderProgramWithName:@"Gray"];
}

// 颠倒滤镜着色器程序
- (void)setupReversalShaderProgram {
    //设置着色器程序
    [self setupShaderProgramWithName:@"Reversal"];
}



// 马赛克滤镜着色器程序
- (void)setupMosaicShaderProgram {
    [self setupShaderProgramWithName:@"Mosaic"];
    
}

// 六边形马赛克滤镜着色器程序
- (void)setupHexagonMosaicShaderProgram {
    [self setupShaderProgramWithName:@"HexagonMosaic"];
}

// 三角形马赛克滤镜着色器程序
- (void)setupTriangularMosaicShaderProgram {
    [self setupShaderProgramWithName:@"TriangularMosaic"];
}

#pragma mark - 着色器程序  着色器
// 初始化着色器程序
- (void)setupShaderProgramWithName:(NSString *)name{
    //1. 获取着色器program
    GLuint program = [self programWithShaderName:name];
    
    //2. use Program
    glUseProgram(program);
    
    //3. 获取Position,Texture,TextureCoords 的索引位置
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    //4.激活纹理,绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    //5.纹理sample
    glUniform1i(textureSlot, 0);
    
    //6.打开positionSlot 属性并且传递数据到positionSlot中(顶点坐标)
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex),
                          NULL+offsetof(SenceVertex, positionCoord));
    
    //7.打开textureCoordsSlot 属性并传递数据到textureCoordsSlot(纹理坐标)
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    //8.保存program,界面销毁则释放
    self.program = program;
}
//link Program
- (GLuint)programWithShaderName:(NSString *)shaderName {
    //1. 编译顶点着色器/片元着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    //2. 将顶点/片元附着到program
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    //3.linkProgram
    glLinkProgram(program);
    
    //4.检查是否link成功
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@", messageString);
        exit(1);
    }
    
    //5.返回program
    return program;
}
//编译shader代码
- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    //1.获取shader 路径
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    //2. 创建shader->根据shaderType
    GLuint shader = glCreateShader(shaderType);
    
    
    //3.获取shader source
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    //4.编译shader
    glCompileShader(shader);
    
    //5.查看编译是否成功
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (GL_COMPILE_STATUS == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    
    //6.返回shader
    return shader;
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

//获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
//获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}
@end
