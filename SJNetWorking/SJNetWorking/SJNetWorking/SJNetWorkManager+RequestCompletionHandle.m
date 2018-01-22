//
//  SJNetWorkManager+RequestCompletionHandle.m
//  SJNetWorking
//
//  Created by Hello on 2018/1/19.
//  Copyright © 2018年 Hello. All rights reserved.
//

#import "SJNetWorkManager+RequestCompletionHandle.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

/*! 系统相册 */
#import <Photos/Photos.h>
#import "UIImage+CompressImage.h"

@implementation SJNetWorkManager (RequestCompletionHandle)
#pragma mark - GET
/**
 网络请求的实例方法 get
 
 @param urlString 请求的地址
 @param isNeedCache 是否需要缓存，只有 get / post 请求有缓存配置
 @param parameters 请求的参数
 @param complectionBlock 请求完成的回调
 @param progressBlock 进度
 @return UrlSessionTask
 */
+ (UrlSessionTask *)GET_WithUrlString:(NSString *)urlString
                          isNeedCache:(BOOL)isNeedCache
                           parameters:(id)parameters
                     complectionBlock:(ComplectionBlock)complectionBlock
                        progressBlock:(DownloadProgressBlock)progressBlock
{
   return [self requestWithType:HttpRequestTypeGet isNeedCache:isNeedCache urlString:urlString parameters:parameters complectionBlock:complectionBlock progressBlock:progressBlock];
}

#pragma mark - POST
/**
 网络请求的实例方法 post
 
 @param urlString 请求的地址
 @param isNeedCache 是否需要缓存，只有 get / post 请求有缓存配置
 @param parameters 请求的参数
 @param complectionBlock 请求完成的回调
 @param progressBlock 进度
 @return UrlSessionTask
 */
+ (UrlSessionTask *)POST_WithUrlString:(NSString *)urlString
                           isNeedCache:(BOOL)isNeedCache
                            parameters:(id)parameters
                      complectionBlock:(ComplectionBlock)complectionBlock
                         progressBlock:(DownloadProgressBlock)progressBlock
{
    return [self requestWithType:HttpRequestTypePost isNeedCache:isNeedCache urlString:urlString parameters:parameters complectionBlock:complectionBlock progressBlock:progressBlock];

}

#pragma mark - PUT
/**
 网络请求的实例方法 put
 
 @param urlString 请求的地址
 @param parameters 请求的参数
 @param complectionBlock 请求完成的回调
 @param progressBlock 进度
 @return UrlSessionTask
 */
+ (UrlSessionTask *)PUT_WithUrlString:(NSString *)urlString
                           parameters:(id)parameters
                     complectionBlock:(ComplectionBlock)complectionBlock
                        progressBlock:(DownloadProgressBlock)progressBlock
{
    return [self requestWithType:HttpRequestTypePut isNeedCache:NO urlString:urlString parameters:parameters complectionBlock:complectionBlock progressBlock:progressBlock];
}

#pragma mark - DELEGATE
/**
 网络请求的实例方法 delete
 
 @param urlString 请求的地址
 @param parameters 请求的参数
 @param complectionBlock 请求完成的回调
 @param progressBlock 进度
 @return UrlSessionTask
 */
+ (UrlSessionTask *)DELETE_WithUrlString:(NSString *)urlString
                              parameters:(id)parameters
                        complectionBlock:(ComplectionBlock)complectionBlock
                           progressBlock:(DownloadProgressBlock)progressBlock
{
    return [self requestWithType:HttpRequestTypePut isNeedCache:NO urlString:urlString parameters:parameters complectionBlock:complectionBlock progressBlock:progressBlock];
}
#pragma mark - 多图上传
/**
 上传图片(多图)
 
 @param urlString urlString description
 @param parameters 上传图片预留参数---视具体情况而定 可为空
 @param imageArray 上传的图片数组
 @param fileNames 上传的图片数组 fileName
 @param imageType 图片类型，如：png、jpg、gif
 @param imageScale 图片压缩比率（0~1.0）
 @param complectionBlock 上传完成的回调
 @param progressBlock 上传进度
 @return UrlSessionTask
 */
+ (UrlSessionTask *)UPLOAD_ImageWithUrlString:(NSString *)urlString
                                   parameters:(id)parameters
                                   imageArray:(NSArray *)imageArray
                                    fileNames:(NSArray <NSString *>*)fileNames
                                    imageType:(NSString *)imageType
                                   imageScale:(CGFloat)imageScale
                             complectionBlock:(ComplectionBlock)complectionBlock
                                progressBlock:(UploadProgressBlock)progressBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    
    NetWeak(self);
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NetLog(@"******************** 请求参数 ***************************");
    NetLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",SJNetManagerShare.afSessionManager.requestSerializer.HTTPRequestHeaders, @"POST",URLString, parameters);
    NetLog(@"********************************************************");
    
    UrlSessionTask *sessionTask = nil;
    sessionTask = [SJNetManagerShare.afSessionManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        /*! 出于性能考虑,将上传图片进行压缩 */
        [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            /*! image的压缩方法 */
            UIImage *resizedImage;
            /*! 此处是使用原生系统相册 */
            if ([obj isKindOfClass:[PHAsset class]])
            {
                PHAsset *asset = (PHAsset *)obj;
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                [imageManager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth , asset.pixelHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    NetLog(@" width:%f height:%f",result.size.width,result.size.height);
                    
                    [self uploadImageWithFormData:formData resizedImage:result imageType:imageType imageScale:imageScale fileNames:fileNames index:idx];
                }];
            }
            else
            {
                /*! 此处是使用其他第三方相册，可以自由定制压缩方法 */
                resizedImage = obj;
                [self uploadImageWithFormData:formData resizedImage:resizedImage imageType:imageType imageScale:imageScale fileNames:fileNames index:idx];
            }
            
        }];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NetLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock)
            {
                progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NetLog(@"上传图片成功 = %@",responseObject);
        if (complectionBlock)
        {
            complectionBlock(responseObject, nil);
        }
        
        [[weakself tasks] removeObject:sessionTask];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (complectionBlock)
        {
            complectionBlock(nil, error);
        }
        [[weakself tasks] removeObject:sessionTask];
    }];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}
#pragma mark - 视频上传
/**
 视频上传
 
 @param urlString 上传的url
 @param parameters 上传视频预留参数---视具体情况而定 可移除
 @param videoPath 上传视频的本地沙盒路径
 @param complectionBlock 完成的回调
 @param progressBlock 上传的进度
 */
+ (void)UPLOAD_VideoWithUrlString:(NSString *)urlString
                       parameters:(id)parameters
                        videoPath:(NSString *)videoPath
                 complectionBlock:(ComplectionBlock)complectionBlock
                    progressBlock:(UploadProgressBlock)progressBlock
{
    /*! 获得视频资源 */
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath]  options:nil];
    
    /*! 压缩 */
    
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    
    /*! 创建日期格式化器 */
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /*! 转化后直接写入Library---caches */
    NSString *videoWritePath = [NSString stringWithFormat:@"output-%@.mp4",[formatter stringFromDate:[NSDate date]]];
    NSString *outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", videoWritePath];
    
    AVAssetExportSession *avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    avAssetExport.outputURL = [NSURL fileURLWithPath:outfilePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:
            {
                [SJNetManagerShare.afSessionManager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    NSURL *filePathURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", outfilePath]];
                    // 获得沙盒中的视频内容
                    [formData appendPartWithFileURL:filePathURL2 name:@"video" fileName:outfilePath mimeType:@"application/octet-stream" error:nil];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    NetLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
                    
                    /*! 回到主线程刷新UI */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressBlock)
                        {
                            progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                        }
                    });
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    NetLog(@"上传视频成功 = %@",responseObject);
                    if (complectionBlock)
                    {
                        complectionBlock(responseObject, nil);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NetLog(@"上传视频失败 = %@", error);
                    if (complectionBlock)
                    {
                        complectionBlock(nil, error);
                    }
                }];
                break;
            }
            default:
                break;
        }
    }];
    
}
#pragma mark - 文件下载
/**
 文件下载
 
 @param urlString 请求的url
 @param parameters 文件下载预留参数---视具体情况而定 可移除
 @param savePath 下载文件保存路径
 @param complectionBlcok 下载文件完成的回调
 @param progressBlock 下载文件的进度显示
 @return UrlSessionTask
 */
+ (UrlSessionTask *)DOWNLOAD_FileWithUrlString:(NSString *)urlString
                                    parameters:(id)parameters
                                      savaPath:(NSString *)savePath
                              complectionBlcok:(ComplectionBlock)complectionBlcok
                                 progressBlock:(DownloadProgressBlock)progressBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NetLog(@"******************** 请求参数 ***************************");
    NetLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",SJNetManagerShare.afSessionManager.requestSerializer.HTTPRequestHeaders, @"download",urlString, parameters);
    NetLog(@"******************************************************");
    
    
    UrlSessionTask *sessionTask = nil;
    
    sessionTask = [SJNetManagerShare.afSessionManager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NetLog(@"下载进度：%.2lld%%",100 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (progressBlock)
            {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
            
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        if (!savePath)
        {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NetLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
        else
        {
            return [NSURL fileURLWithPath:savePath];
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self tasks] removeObject:sessionTask];
        
        NetLog(@"下载文件成功");
        if (error == nil)
        {
            if (complectionBlcok)
            {
                /*! 返回完整路径 */
                complectionBlcok([filePath path], nil);
            }
            else
            {
                if (complectionBlcok)
                {
                    complectionBlcok(nil, error);
                }
            }
        }
    }];
    
    /*! 开始启动任务 */
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}
#pragma mark - 文件上传
/**
 文件上传
 
 @param urlString 请求的url
 @param parameters 文件上传预留参数---视具体情况而定 可为空
 @param fileName 上传文件名称
 @param filePath 上传文件路径
 @param complectionBlock 上传文件成功回调
 @param progressBlock 上传文件的进度显示
 @return UrlSessionTask
 */
+ (UrlSessionTask *)UPLOAD_FileWithUrlString:(NSString *)urlString
                                  parameters:(id)parameters
                                    fileName:(NSString *)fileName
                                    filePath:(NSString *)filePath
                            complectionBlock:(ComplectionBlock)complectionBlock
                               progressBlock:(UploadProgressBlock)progressBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    
    NetLog(@"******************** 请求参数 ***************************");
    NetLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",SJNetManagerShare.afSessionManager.requestSerializer.HTTPRequestHeaders, @"uploadFile", urlString, parameters);
    NetLog(@"******************************************************");
    
    UrlSessionTask *sessionTask = nil;
    sessionTask = [SJNetManagerShare.afSessionManager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:fileName error:&error];
        if (complectionBlock && error)
        {
            complectionBlock(nil, error);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NetLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock)
            {
                progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self tasks] removeObject:sessionTask];
        if (complectionBlock)
        {
            complectionBlock(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self tasks] removeObject:sessionTask];
        if (complectionBlock)
        {
            complectionBlock(nil, error);
        }
    }];
    
    /*! 开始启动任务 */
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}


#pragma mark - 私有方法
#pragma mark - 网络请求的类方法 --- get / post / put / delete
/*!
 *  网络请求的实例方法
 *
 *  @param type         get / post / put / delete
 *  @param isNeedCache  是否需要缓存，只有 get / post 请求有缓存配置
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param complectionBlock 请求成功的回调
 *  @param progressBlock 进度
 *  @return UrlSessionTask
 */
+ (UrlSessionTask *)requestWithType:(HttpRequestType)type
                        isNeedCache:(BOOL)isNeedCache
                          urlString:(NSString *)urlString
                         parameters:(id)parameters
                   complectionBlock:(ComplectionBlock)complectionBlock
                      progressBlock:(DownloadProgressBlock)progressBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    
    NetWeak(self);
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NSString *requestType;
    switch (type) {
        case 0:
            requestType = @"GET";
            break;
        case 1:
            requestType = @"POST";
            break;
        case 2:
            requestType = @"PUT";
            break;
        case 3:
            requestType = @"DELETE";
            break;
        default:
            break;
    }
    
//    AFHTTPSessionManager *scc = SJNetManagerShare.afSessionManager;
//    AFHTTPResponseSerializer *scc2 = scc.responseSerializer;
//    AFHTTPRequestSerializer *scc3 = scc.requestSerializer;
//    NSTimeInterval timeoutInterval = SJNetManagerShare.timeoutInterval;
//
//    NSString *isCache = isNeedCache ? @"开启":@"关闭";
//    CGFloat allCacheSize = [SJNetWorkCache getAllHttpCacheSize];
    
//    NetLog(@"\n******************** 请求参数 ***************************");
//    NetLog(@"\n请求头: %@\n超时时间设置：%.1f 秒【默认：30秒】\nAFHTTPResponseSerializer：%@【默认：AFJSONResponseSerializer】\nAFHTTPRequestSerializer：%@【默认：AFJSONRequestSerializer】\n请求方式: %@\n请求URL: %@\n请求param: %@\n是否启用缓存：%@【默认：开启】\n目前总缓存大小：%.6fM\n", SJNetManagerShare.afSessionManager.requestSerializer.HTTPRequestHeaders, timeoutInterval, scc2, scc3, requestType, URLString, parameters, isCache, allCacheSize);
//    NetLog(@"\n********************************************************");
    
    UrlSessionTask *sessionTask = nil;
    
    // 读取缓存
    id responseObject = [SJNetWorkCache httpCacheWithUrlString:urlString parameters:parameters];
    
    if (type == HttpRequestTypeGet)
    {
        sessionTask = [SJNetManagerShare.afSessionManager GET:URLString parameters:parameters  progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (complectionBlock)
            {
                complectionBlock(responseObject, nil);
            }
            // 对数据进行异步缓存
            [SJNetWorkCache setHttpCache:responseObject urlString:urlString parameters:parameters];
            [[weakself tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (complectionBlock)
            {
                complectionBlock(isNeedCache ? responseObject : nil, error);
            }
            [[weakself tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == HttpRequestTypePost)
    {
        sessionTask = [SJNetManagerShare.afSessionManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            NetLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
            
            /*! 回到主线程刷新UI */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock)
                {
                    progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                }
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NetLog(@"post 请求数据结果： *** %@", responseObject);
            
            if (complectionBlock)
            {
                complectionBlock(responseObject, nil);
            }
            // 对数据进行异步缓存
            [SJNetWorkCache setHttpCache:responseObject urlString:urlString parameters:parameters];
            [[weakself tasks] removeObject:sessionTask];

            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NetLog(@"错误信息：%@",error);
            
          
            if (complectionBlock)
            {
                complectionBlock(isNeedCache ? responseObject : nil, error);
            }
            [[weakself tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == HttpRequestTypePut)
    {
        sessionTask = [SJNetManagerShare.afSessionManager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (complectionBlock)
            {
                complectionBlock(responseObject, nil);
            }
            [[weakself tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
            if (complectionBlock)
            {
                complectionBlock(nil, error);
            }
            [[weakself tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == HttpRequestTypeDelete)
    {
        sessionTask = [SJNetManagerShare.afSessionManager DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (complectionBlock)
            {
                complectionBlock(responseObject, nil);
            }
            
            [[weakself tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (complectionBlock)
            {
                complectionBlock(nil, error);
            }
            [[weakself tasks] removeObject:sessionTask];
            
        }];
    }
    
    if (sessionTask)
    {
        [[weakself tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}

#pragma mark - url 中文格式化
+ (NSString *)strUTF8Encoding:(NSString *)str
{
#ifdef IS_IOS9
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
#else
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#endif
}

#pragma mark - 图片压缩方法
+ (void)uploadImageWithFormData:(id<AFMultipartFormData>  _Nonnull )formData
                      resizedImage:(UIImage *)resizedImage
                         imageType:(NSString *)imageType
                        imageScale:(CGFloat)imageScale
                         fileNames:(NSArray <NSString *> *)fileNames
                             index:(NSUInteger)index
{
    /*! 此处压缩方法是jpeg格式是原图大小的0.8倍，要调整大小的话，就在这里调整就行了还是原图等比压缩 */
    if (imageScale == 0)
    {
        imageScale = 0.8;
    }
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, imageScale ?: 1.f);
    
    /*! 拼接data */
    if (imageData != nil)
    {   // 图片数据不为空才传递 fileName
        //                [formData appendPartWithFileData:imgData name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@" image/jpeg"];
        
        // 默认图片的文件名, 若fileNames为nil就使用
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str, index, imageType?:@"jpg"];
        
        [formData appendPartWithFileData:imageData
                                    name: fileNames[index]
                                fileName:fileNames ? [NSString stringWithFormat:@"%@.%@",fileNames[index],imageType?:@"jpg"] : imageFileName
                                mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        NetLog(@"上传图片 %lu 成功", (unsigned long)index);
    }
}

@end
#pragma mark - NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建 NSDictionary 与 NSArray 的分类, 控制台打印 json 数据中的中文
 ************************************************************************************
 */

#ifdef DEBUG
@implementation NSArray (BANetManager)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    
    [strM appendString:@")"];
    
    return strM;
}

@end

@implementation NSDictionary (BANetManager)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
@end

#endif
