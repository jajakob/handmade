/*
  TODO(jake):  THIS IS NOT A FINAL PLATFORM LAYER!!!
  - Saved game locations
  - Getting a handle to our own executable file
  - Asset loading path
  - Threading (launch a thread)
  - Raw Input (support for multiple keyboards)
  - Sleep/timeBeginPeriod
  - ClipCursor() (for multimonitor support)
  - Fullscreen support
  - WM_SETCURSOR (control cursor visibility)
  - QueryCancelAutoplay
  - WM_ACTIVATEAPP (for when we are not the active application)
  - Blit speed improvements (BitBlt)
  - Hardware acceleration (OpenGL or Direct3D or BOTH??)
  - GetKeyboardLayout (for French keyboards, international WASD support)
  Just a partial list of stuff!!
*/


// TODO(jake): Include stdio.h, stdint.h, and defines in handmade.h?
// TODO(jake): Implement sine ourselves
#include <AppKit/AppKit.h>
#include <Metal/Metal.h>
#include <QuartzCore/QuartzCore.h>

#include <stdio.h>
#include <mach/mach_time.h>

// #include <OpenGL/gl.h>

#include "handmade.c"
#include "handmade_keycodes.h"

global_variable bool32 running = true;
global_variable OffscreenBuffer global_backbuffer;
global_variable id<MTLBuffer> vertex_buffer;


typedef struct MetalParams {
  id<MTLDevice> device;
  id<MTLCommandQueue> command_queue;
  MTLRenderPipelineDescriptor* pipeline_descr;
  id<MTLRenderPipelineState> render_pipeline_state;
} MetalParams;

global_variable MetalParams mtl;

// TODO
// internal void* debugPlatformReadEntireFile(char* filename) { return NULL; }
// internal void debugPlatformFreeFileMemory(void* memory) {}
// internal bool32 debugPlatformWriteEntireFile(char* filename, 
//                                              uint32_t size_memory, 
//                                              void* memory) {
//   return true;
// }

@interface WindowDelegate : NSObject<NSWindowDelegate> {} 
@end

@implementation WindowDelegate
-(BOOL)windowShouldClose:(NSWindow *)sender {
    running = false;
    return !running;
}

- (NSSize)windowWillResize:(NSWindow *)sender 
                    toSize:(NSSize)frameSize {
    
    reallocateBuffer(&global_backbuffer, frameSize.width, frameSize.height);
    // TODO(jake): Probably clear this to black
    return frameSize;
}

// - (void)windowDidBecomeMain:(NSNotification *)notification {
//   NSWindow* window = (NSWindow*) notification.object;
//   window.alphaValue = 1.f;
//   [window orderFrontRegardless];
// }

// - (void)windowDidResignMain:(NSNotification *)notification {
//   NSWindow* window = (NSWindow*) notification.object;
//   window.alphaValue = 0.5f;
//   [window orderFrontRegardless];
// }

@end

// @interface SimpleView : NSView {}
// @end

// @implementation SimpleView

// - (BOOL)acceptsFirstResponder {
//     return YES;
// }

// - (BOOL)acceptsFirstMouse:(NSEvent *)event {
//     return YES;
// }

// - (void)keyDown:(NSEvent *)event {
//     // NSLog(@"Key down: %@\n", event.characters);
//     // printf("Key up %d\n", (uint32_t)event.keyCode);
//     if (event.keyCode == vk_q || event.keyCode == vk_esc) {
//         running = false;
//     } else if (event.keyCode == vk_a) {

//     }
// }

// - (void)keyUp:(NSEvent *)event {
//     // const char* key = [event.characters UTF8String];
//     // NSLog(@"Key up: %@\n", event.characters);
//     // printf("Key up %s\n", key);
// }

// - (BOOL)canBecomeKeyView {
//     return YES;
// }
// @end

// @interface ApplicationDelegate : NSObject <NSApplicationDelegate>
// @end

// @implementation ApplicationDelegate

// - (void)applicationDidFinishLaunching:(NSNotification *)notification
// {
//     @autoreleasepool {

//     NSEvent* event = [NSEvent otherEventWithType:NSEventTypeApplicationDefined
//                               location:NSMakePoint(0, 0)
//                               modifierFlags:0
//                               timestamp:0
//                               windowNumber:0
//                               context:nil
//                               subtype:0
//                               data1:0
//                               data2:0];
    
//     [NSApp postEvent:event atStart:YES];

//     } // autoreleasepool
//     [NSApp stop:nil];
// }

// @end

internal void macOSProcessButton(ButtonState* old_state,
                                 ButtonState* new_state) {
  new_state->is_down_ended = true;
  new_state->half_transition_count = (old_state->is_down_ended 
                                    != new_state->is_down_ended) ? 1 : 0;

}

internal void macOSDisplayBufferInWindow(NSWindow* window, OffscreenBuffer* buffer) {
    @autoreleasepool {
        // NOTE(jake): maybe create a struct like bitmapinfo for all hardcoding
        NSBitmapImageRep* rep = [[
            [NSBitmapImageRep alloc]
                initWithBitmapDataPlanes: (uint8_t**) &buffer->memory
                pixelsWide:buffer->width
                pixelsHigh:buffer->height
                bitsPerSample: 8
                samplesPerPixel: 4
                hasAlpha: YES
                isPlanar: NO
                colorSpaceName: NSDeviceRGBColorSpace
                bytesPerRow: buffer->pitch
                bitsPerPixel: 32
            ] 
            autorelease
        ];

        window.contentView.layer.contents = (id) rep.CGImage;
    }

    // CAMetalLayer* layer = (CAMetalLayer*) window.contentView.layer;

    // layer.drawableSize = CGSizeMake(buffer->width, buffer->height);
    // id<CAMetalDrawable> drawable = [layer nextDrawable];
    // id<MTLCommandBuffer> command_buffer = [mtl.command_queue commandBuffer];
    
    // MTLRenderPassDescriptor* rpd = [MTLRenderPassDescriptor new];
    // MTLRenderPassColorAttachmentDescriptor* cd = rpd.colorAttachments[0];
    // cd.texture = drawable.texture;
    // cd.loadAction = MTLLoadActionClear;
    // cd.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
    // cd.storeAction = MTLStoreActionStore;
    // id<MTLRenderCommandEncoder> render_enc = [
    //   command_buffer renderCommandEncoderWithDescriptor:rpd];
    // [render_enc setRenderPipelineState:mtl.render_pipeline_state];
    // [render_enc setVertexBuffer:vertex_buffer offset:0 atIndex:0];
    // [render_enc drawPrimitives:MTLPrimitiveTypeTriangle 
    //             vertexStart:0 vertexCount:3];
    // [render_enc endEncoding];
    // [command_buffer presentDrawable:drawable];
    // [command_buffer commit];

  // glViewport(0, 0, buffer->width, buffer->height);
  // glClearColor(1.f, 0.f, 0.f, 1.f);
  // glClear(GL_COLOR_BUFFER_BIT);
  // SwapBuffers();
}

void macOSProcessKeyboard(uint16_t keycode, bool32 is_down, 
                          EngineInput* input) {
  if (is_down && (keycode == vk_q || keycode == vk_esc)) {
    running = false;
  }
  if (keycode == vk_d) {
    input->controller.key_d.is_down_ended = is_down;
  } else if (keycode == vk_a) {
    input->controller.key_a.is_down_ended = is_down;
  } else if (keycode == vk_w) {
    input->controller.key_w.is_down_ended = is_down;
  } else if (keycode == vk_s) {
    input->controller.key_s.is_down_ended = is_down;
  }
}


inline internal float macOSGetSecondsElapsed(uint64_t start, uint64_t end) {
  local_persist mach_timebase_info_data_t timebase_info;
  uint64_t elapsed = end - start; 
  if (timebase_info.denom == 0) {
    mach_timebase_info(&timebase_info);
  }
  uint64_t elapsed_nano = elapsed * timebase_info.numer / timebase_info.denom;
  float spf = (float)(elapsed_nano * 1.0E-9);
  return spf;
}

// internal void macOSInitOpenGL() {
//   NSOpenGLPixelFormatAttribute attributes[40];
// }

internal void macOSInitMetal() {
  mtl.device = MTLCreateSystemDefaultDevice();
  mtl.command_queue = [mtl.device newCommandQueue];
  
  MTLCompileOptions* compileOptions = [MTLCompileOptions new];
  compileOptions.languageVersion = MTLLanguageVersion1_1;
  NSError* error;
  id<MTLLibrary> lib = [
    mtl.device 
    newLibraryWithSource:
      @"#include <metal_stdlib>\n"
      "using namespace metal;\n"
      "vertex float4 v_simple(\n"
      "    constant float4* in  [[buffer(0)]],\n"
      "    uint             vid [[vertex_id]])\n"
      "{\n"
      "    return in[vid];\n"
      "}\n"
      "fragment float4 f_simple(\n"
      "    float4 in [[stage_in]])\n"
      "{\n"
      "    return float4(1, 0, 0, 1);\n"
      "}\n"
      options:compileOptions error:&error];

  if (!lib) {
    NSLog(@"Can't create library: %@", error);
  }

  mtl.pipeline_descr = [MTLRenderPipelineDescriptor new];
  mtl.pipeline_descr.label = @"Simple Pipeline";
  mtl.pipeline_descr.vertexFunction = [lib newFunctionWithName:@"v_simple"];
  mtl.pipeline_descr.fragmentFunction = [lib newFunctionWithName:@"f_simple"];
  
  mtl.pipeline_descr.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
  mtl.render_pipeline_state = [
    mtl.device 
    newRenderPipelineStateWithDescriptor:mtl.pipeline_descr 
    error:&error];
  if (!mtl.render_pipeline_state) {
    NSLog(@"Can't create render pipeline state: %@", error);
  }

  float vertices_[12] = {
    0, 0, 0, 1,
    -1, 1, 0, 1,
    1, 1, 0, 1};

   vertex_buffer = [
      mtl.device 
      newBufferWithBytes:vertices_
      length:sizeof(vertices_)
      options:MTLResourceOptionCPUCacheModeDefault];

  // ImGui_ImplMetal_Init(device);
}

int main() {
    // macOSInitMetal();
    reallocateBuffer(&global_backbuffer, 600, 500);
    
    // typedef CGRect NSRect;
    NSRect content_rect = {
        {0, 0}, {global_backbuffer.width, global_backbuffer.height}};

    NSWindow* window = [
        [NSWindow alloc]
        initWithContentRect: content_rect
        styleMask: NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|
                   NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
        backing: NSBackingStoreBuffered
        defer: NO
    ];
    window.delegate = [WindowDelegate new];
    window.title = @"Handmade";
    // window.contentView = [[SimpleView alloc] init];
    // CAMetalLayer* layer = [CAMetalLayer layer];
    // layer.device = mtl.device;
    // layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    // window.contentView.layer = layer;
    window.contentView.wantsLayer = YES;

    window.acceptsMouseMovedEvents = YES;
    [window makeFirstResponder: window.contentView];
    [window makeKeyAndOrderFront: nil];
    
    [NSApplication sharedApplication];
    // [NSApp setDelegate: [[[ApplicationDelegate alloc] init] autorelease]];

    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    int monitor_refresh_hz = 60;
    int engine_update_hz = monitor_refresh_hz / 2;
    float target_spf = 1.f / (float)engine_update_hz;

    EngineMemory engine_memory = {};
#if INTERNAL
    void* base_address = (void*) Terabytes(2);
#else
    void* base_address = 0;
#endif
    engine_memory.permanent_storage_size = Megabytes(64);
    engine_memory.transient_storage_size = Gigabytes(4);
    uint64_t total_size = engine_memory.permanent_storage_size 
                        + engine_memory.transient_storage_size;

    // engine_memory.permanent_storage = malloc(engine_memory.permanent_storage_size);
    // engine_memory.transient_storage = malloc(engine_memory.transient_storage_size);
    engine_memory.permanent_storage = mmap(base_address, total_size, 
                                           PROT_READ | PROT_WRITE, 
                                           MAP_PRIVATE | MAP_ANON, -1, 0);

    engine_memory.transient_storage = (uint8_t*)engine_memory.permanent_storage
                                    + engine_memory.permanent_storage_size;

    if (engine_memory.permanent_storage && engine_memory.transient_storage) {

      uint64_t start = mach_absolute_time();
      // currently uses 100% cpu, because of no vsync, see
      // https://hero.handmade.network/forums/code-discussion/t/1409-main_game_loop_on_os_x

      EngineInput input = {};

      while (running) {

          @autoreleasepool {
              // for (;;) {
              //     NSEvent* event = [NSApp nextEventMatchingMask: NSEventMaskAny
              //                             untilDate: nil
              //                             inMode: NSDefaultRunLoopMode
              //                             dequeue: YES];
              //     if (!event)
              //         break;
              //     [NSApp sendEvent: event];
              // }
              for (;;) {
                  NSEvent* event = [NSApp nextEventMatchingMask: NSEventMaskAny
                                          untilDate: nil
                                          inMode: NSDefaultRunLoopMode
                                          dequeue: YES];
                  if (!event)
                      break;
                  switch(event.type) {
                    case NSEventTypeKeyDown: {
                      NSLog(@"Key down: %@, %d\n", event.characters, (uint32_t)event.keyCode);
                      macOSProcessKeyboard(event.keyCode, true, &input);
                    } break;
                    case NSEventTypeKeyUp: {
                      NSLog(@"Key up: %@, %d\n", event.characters, (uint32_t)event.keyCode);
                      macOSProcessKeyboard(event.keyCode, false, &input);

                    } break;
                    default: [NSApp sendEvent: event]; break;
                  }
                  
              }
          }

          updateAndRender(&input, &engine_memory, &global_backbuffer);
          macOSDisplayBufferInWindow(window, &global_backbuffer);

          uint64_t end = mach_absolute_time();
          float spf = macOSGetSecondsElapsed(start, end);

          // TODO(jake): Not tested yet, maybe buggy!!
          float s_elapsed_for_frame = spf;
          if (s_elapsed_for_frame < target_spf) {
            uint32_t us_sleep = (uint32_t)(
                                1000000.f * (target_spf - s_elapsed_for_frame));
            usleep(us_sleep);
            
            // float test_spf = macOSGetSecondsElapsed(start, mach_absolute_time());
            // Assert(test_spf < target_spf, "ouch\n");
            while (s_elapsed_for_frame < target_spf) {
              s_elapsed_for_frame = macOSGetSecondsElapsed(
                  start, mach_absolute_time());
            }
          } else {
            // TODO(jake): MISSED FRAME RATE
          }
          end = mach_absolute_time();
          float mspf = 1000.f * macOSGetSecondsElapsed(start, end);
          // float fps = 1.f / spf;
          float fps = 1.f / s_elapsed_for_frame;
          // printf("mspf %f, fps %f\n", mspf, fps);

          start = end;
      }
    }
    
    return 0;
}