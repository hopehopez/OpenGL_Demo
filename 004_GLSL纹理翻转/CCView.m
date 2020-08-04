//
//  CCView.m
//  003_GLSL
//
//  Created by zsq on 2020/7/31.
//  Copyright © 2020 zsq. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import "CCView.h"

@interface CCView()

//核心动画 -> 特殊图层的一种
@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
@property (nonatomic, strong) EAGLContext *myContext;

@property (nonatomic, assign) GLuint myColorRenderBuffer;
@property (nonatomic, assign) GLuint myColorFrameBuffer;

@property (nonatomic, assign) GLuint myPrograme;
@end

@implementation CCView

- (void)layoutSubviews{
    //1.设置图层
       [self setupLayer];
       
       //2.设置图形上下文
       [self setupContext];
       
       //3.清空缓存区
       [self deleteRenderAndFrameBuffer];

       //4.设置RenderBuffer
       [self setupRenderBuffer];
       
       //5.设置FrameBuffer
       [self setupFrameBuffer];
       
       //6.开始绘制
       [self renderLayer];
}

+ (Class)layerClass{
    //重写layerClass，将CCView返回的图层从CALayer替换成CAEAGLLayer
    return [CAEAGLLayer class];
}

#pragma mark - 6.开始绘制
-(void)renderLayer{
    glClearColor(0.3, 0.45, 0.5, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    //1.设置视口大小
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x*scale, self.frame.origin.y, self.frame.size.width*scale, self.frame.size.height*scale);
    
    //2.读取顶点着色程序 片元着色程序
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertFile);
    NSLog(@"fragFile:%@",fragFile);
    
    //3.加载shader
    self.myPrograme = [self loadShaders:vertFile Withfrag:fragFile];
    
    //4.链接
    glLinkProgram(self.myPrograme);
    
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    NSLog(@"Program Link Success!");
    
    //5.使用program
    glUseProgram(self.myPrograme);
    
    //6.设置顶点 纹理坐标
//    GLfloat attrArr[] = {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };
    
    //解决纹理导致(方法5)
    //直接从源纹理坐标数据修改
    GLfloat attrArr[] =
    {
    0.5f, -0.5f, 0.0f,        1.0f, 1.0f, //右下
    -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
    -0.5f, -0.5f, 0.0f,       0.0f, 1.0f, // 左下
    0.5f, 0.5f, 0.0f,         1.0f, 0.0f, // 右上
    -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
    0.5f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
    };
    
    //7.处理顶点数据
    //1)顶点缓冲区
    GLuint attrBuffer;
    //2)申请一个缓冲区标志符
    glGenBuffers(1, &attrBuffer);
    //3)将attrBuffer绑定到GL_ARRAY_BUFFER标识符上
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    //4)把顶点数据从CPU内存复制到GPU上
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    //8.将顶点数据通过myPrograme 传递到顶点着色程序的position
    //1)获取顶点数据通道ID
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    
    //2)设置合适的格式从buffer里面读取数据
    //打开通道
    glEnableVertexAttribArray(position);
    
    //3)设置读取方式
    //参数1：index,顶点数据的索引
    //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
    //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    //参数5：stride,连续顶点属性之间的偏移量，默认为0；
    //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    //9.处理纹理数据
    GLuint textCoor = glGetAttribLocation(self.myPrograme, "textCoordinate");
    
    glEnableVertexAttribArray(textCoor);
    
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);
    
    //10.加载纹理
    [self setupTexture:@"kunkun"];
    
    //11.设置纹理采样器  0 纹理
    glUniform1i(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
    
    //解决纹理导致(方法1)
//    [self rotateTextureImage];
    
    //12绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    //13.从渲染缓冲区显示到屏幕上
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)rotateTextureImage{
    //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    //1. rotate等于shaderv.vsh中的uniform属性，rotateMatrix
    GLuint rotate = glGetUniformLocation(self.myPrograme, "rotateMatrix");
    
    //2.获取渲旋转的弧度
    float radians = 180 * 3.14159f / 180.0f;
    
     //3.求得弧度对于的sin\cos值
    float s = sin(radians);
    float c = cos(radians);
    
    //4.
    /*
        参考Z轴旋转矩阵
        */
    GLfloat zRotation[16] = {
        c,-s,0,0,
        s,c,0,0,
        0,0,1,0,
        0,0,0,1
    };
    
    //5.设置旋转矩阵
    /*
     glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
     location : 对于shader 中的ID
     count : 个数
     transpose : 转置
     value : 指针
     */
    glUniformMatrix4fv(rotate, 1, GL_FALSE, zRotation);
}

//从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName {
     //1、将 UIImage 转换为 CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片的大小，宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //3.获取图片字节数 宽*高*4（RGBA）
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的每一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //5、在CGContextRef上--> 将图片绘制出来
    /*
     CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
     CGContextDrawImage
     参数1：绘图上下文
     参数2：rect坐标
     参数3：绘制的图片
     */
    CGRect rect = CGRectMake(0, 0, width, height);
    //使用默认方式绘制
    CGContextDrawImage(spriteContext, rect, spriteImage);
  
    /*
    //解决纹理倒置方法2 解压图片时,将图片源文件翻转
    //先向下平移图片高度 的距离
    CGContextTranslateCTM(spriteContext, 0, height);
    //通过y轴-1倍缩放实现翻转
    CGContextScaleCTM(spriteContext, 1, -1);
    //再绘制
    CGContextDrawImage(spriteContext, rect, spriteImage);
     */
    
    //6.释放上下文
    CGContextRelease(spriteContext);
    
    //7.绑定纹理到默认的纹理ID 只有一个纹理时 纹理id默认为0 同时默认激活
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //8.设置纹理属性
    /*
     参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    //9.载入纹理2D数据
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //10.释放spriteData
    free(spriteData);
    
    return 0;
}

#pragma mark - 5.frame buffer
- (void)setupFrameBuffer{
    GLuint buffer;
    
    glGenBuffers(1, &buffer);
    
    self.myColorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    /*生成帧缓存区之后，则需要将renderbuffer跟framebuffer进行绑定，
        调用glFramebufferRenderbuffer函数进行绑定到对应的附着点上，后面的绘制才能起作用
        */
       
    //5.将渲染缓存区myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到 GL_COLOR_ATTACHMENT0上。
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

#pragma mark - 4.render buffer
- (void)setupRenderBuffer{
    //1.定义bufferID
    GLuint buffer;
     //2.申请一个缓存区标志
    glGenRenderbuffers(1, &buffer);
    
    //3.
    self.myColorRenderBuffer = buffer;
    
    //4.将标识符绑定到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    
    //5.将可绘制对象drawable object's  CAEAGLLayer的存储绑定到OpenGL ES renderBuffer对象
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

#pragma mark - 3. 清空缓冲区
- (void)deleteRenderAndFrameBuffer{
    //1.Frame Buffer Object: FBO
    //Render Buffer 分为三个类别:颜色缓冲区 深度缓冲区 模板缓冲区
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
}

#pragma mark - 2. 设置上下文
- (void)setupContext{
    //1.指定OpenGL ES 渲染API版本，我们使用2.0
    //2.创建图形上下文
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!context) {
        NSLog(@"create content failed");
        return;
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext failed");
        return;
    }
    //5.将局部context，变成全局的
    self.myContext = context;
}
#pragma mark - 1.设置图层
- (void)setupLayer{
    //1.创建特殊图层
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    //2.设置scale
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    //3.设置描述属性，这里设置不维持渲染内容以及颜色格式为RGBA8
    /*
     kEAGLDrawablePropertyRetainedBacking  表示绘图表面显示后，是否保留其内容。
     kEAGLDrawablePropertyColorFormat
     可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8；
     
     kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
     kEAGLColorFormatRGB565：16位RGB的颜色，
     kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
     
     
     */
    self.myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @false,
                                           kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
}

#pragma mark - shader
//加载shader
-(GLuint)loadShaders:(NSString *)vert Withfrag:(NSString *)frag {
    //1.定义顶点着色器对象 片元着色器对象
    GLuint verShader, fragShader;
    
    //2.创建 program
    GLuint program = glCreateProgram();
    
    //3.编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //4.编译好的shader附着到program
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //5.删除
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

//编译shader
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //1.读取路径
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    //2.创建一个对应类型的shader
    *shader = glCreateShader(type);
    
    //3.将着色器源码附着到着色器对象上
    glShaderSource(*shader, 1, &source, NULL);
    
    //4.编译
    glCompileShader(*shader);
}
@end
