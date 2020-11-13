//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<export_video_frame/ExportVideoFramePlugin.h>)
#import <export_video_frame/ExportVideoFramePlugin.h>
#else
@import export_video_frame;
#endif

#if __has_include(<firebase_ml_vision/FLTFirebaseMlVisionPlugin.h>)
#import <firebase_ml_vision/FLTFirebaseMlVisionPlugin.h>
#else
@import firebase_ml_vision;
#endif

#if __has_include(<image_picker/FLTImagePickerPlugin.h>)
#import <image_picker/FLTImagePickerPlugin.h>
#else
@import image_picker;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ExportVideoFramePlugin registerWithRegistrar:[registry registrarForPlugin:@"ExportVideoFramePlugin"]];
  [FLTFirebaseMlVisionPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseMlVisionPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
}

@end
