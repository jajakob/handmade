#include <stdio.h>
#include <stdint.h> 

#import <AppKit/AppKit.h>

#define internal static
#define local_persist static
#define global_variable static

global_variable int width = 600;
global_variable int height = 600;
global_variable bool running = true;
global_variable uint8_t* buffer;
global_variable int bytes_per_pixel = 4; // rgba
global_variable int pitch;

const uint16_t vk_esc = 0x35;
const uint16_t vk_q = 0x0c;


// TODO(jake): Put this in a separate file
@interface WindowDelegate : NSObject<NSWindowDelegate> {} 
@end

@implementation WindowDelegate
-(BOOL)windowShouldClose:(NSWindow *)sender {
    running = false;
    return !running;
}

- (NSSize)windowWillResize:(NSWindow *)sender 
                    toSize:(NSSize)frameSize {
    
    // TODO(jake): put this in a separate function
    if (buffer)
        free(buffer);
    width = frameSize.width;
    height = frameSize.height;
    pitch = bytes_per_pixel * width;
    buffer = malloc(pitch * height);
    // TODO(jake): Probably clear this to black
    return frameSize;
}

@end

@interface SimpleView : NSView {}
@end

@implementation SimpleView

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"Key down: %@\n", event.characters);
    // printf("Key up %d\n", (uint32_t)event.keyCode);
    if (event.keyCode == vk_q || event.keyCode == vk_esc) {
        running = false;
    }
}

- (void)keyUp:(NSEvent *)event {
    // const char* key = [event.characters UTF8String];
    // NSLog(@"Key up: %@\n", event.characters);
    // printf("Key up %s\n", key);
}

- (BOOL)canBecomeKeyView {
    return YES;
}
@end

internal void renderWeirdGradient(int x_offset, int y_offset) {
    uint8_t* row = buffer;
    for (size_t y = 0; y < height; y++) {   
        
        uint32_t* pixel = (uint32_t*) row; 

        for (size_t x = 0; x < width; x++) {
            uint8_t blue = x + x_offset;
            uint8_t green = y + y_offset;
            // RGBA -> ABGR
            *pixel++ = (255 << 24) | (blue << 16) | (green << 8);
        }
        row += pitch;
    }

}

internal void updateWindow(NSWindow* window) {
    @autoreleasepool {
        // NOTE(jake): maybe create a struct like bitmapinfo for all hardcoding
        NSBitmapImageRep* rep = [
                [NSBitmapImageRep alloc]
                initWithBitmapDataPlanes: &buffer 
                pixelsWide:width 
                pixelsHigh:height 
                bitsPerSample: 8
                samplesPerPixel: 4 
                hasAlpha: YES
                isPlanar: NO
                colorSpaceName: NSDeviceRGBColorSpace
                bytesPerRow: pitch
                bitsPerPixel: 8 * bytes_per_pixel
        ];

        window.contentView.layer.contents = (id) rep.CGImage;
    }
}

int main() {

    // // typedef CGRect NSRect;
    NSRect content_rect = {0, 0, 600, 500};

    NSWindow* window = [
        [NSWindow alloc]
        initWithContentRect: content_rect
        styleMask: NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|
                   NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
        backing: NSBackingStoreBuffered
        defer: NO
    ];
    window.delegate = [[WindowDelegate alloc] init];
    window.title = @"Handmade";
    window.contentView = [[SimpleView alloc] init];
    window.contentView.wantsLayer = YES;
    window.acceptsMouseMovedEvents = YES;
    [window makeFirstResponder: window.contentView];
    [window makeKeyAndOrderFront: nil];
    
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];


    width = window.contentView.bounds.size.width;
    height = window.contentView.bounds.size.height;
    pitch = bytes_per_pixel * width;
    buffer = malloc(pitch * height);
    
    int x_offset = 0;
    while(running) {
        
        @autoreleasepool {
            for(;;) {
                NSEvent* event = [NSApp nextEventMatchingMask: NSEventMaskAny
                                        untilDate: nil
                                        inMode: NSDefaultRunLoopMode
                                        dequeue: YES];
                if (!event)
                    break;
                [NSApp sendEvent: event];
            }
        }

        renderWeirdGradient(x_offset, 0);
        updateWindow(window);
        ++x_offset;
        
    }

    
    return 0;
}