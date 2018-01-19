//
//  SJNetWorkManager+RequestCompletionHandle.h
//  SJNetWorking
//
//  Created by Hello on 2018/1/19.
//  Copyright © 2018年 Hello. All rights reserved.
//

#import "SJNetWorkManager.h"

@interface SJNetWorkManager (RequestCompletionHandle)

#pragma mark - 网络请求的类方法 --- get / post / put / delete
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
                        progressBlock:(DownloadProgressBlock)progressBlock;

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
                        progressBlock:(DownloadProgressBlock)progressBlock;

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
                                    progressBlock:(DownloadProgressBlock)progressBlock;

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
                           progressBlock:(DownloadProgressBlock)progressBlock;

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
                                progressBlock:(UploadProgressBlock)progressBlock;

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
                      progressBlock:(UploadProgressBlock)progressBlock;

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
                                 progressBlock:(DownloadProgressBlock)progressBlock;

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
                                   progressBlock:(UploadProgressBlock)progressBlock;


@end
