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

@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
@property (nonatomic, strong) EAGLContext *myContext;

@property (nonatomic, assign) GLuint myColorRenderBuffer;
@property (nonatomic, assign) GLuint myColorFrameBuffer;

@property (nonatomic, assign) GLuint myPrograme;
@end

@implementation CCView

- (void)layoutSubviews{
    
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
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
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:vert];
    
    //4.shader附着到program
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //5.删除
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return 0;
}

//编译shader
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //1.读取路径
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    //2.创建一个对应类型的shader
    *shader = glCreateShader(type);
    
    //3.将着色器源码附着到着色器对象上
    glShaderSource(*shader, 1, &cource, NULL);
    
    //4.编译
    glCompileShader(*shader);
}
@end
