#pragma once

#include <math.h>
#include <stdint.h>

#define internal static
#define local_persist static
#define global_variable static

#define Pi32 3.14159265359f

typedef int32_t bool32;

/* 
  NOTE(jake): 
  INTERNAL:
    0 - Build for public release
    1 - Build for developer only

  SLOW:
    0 - Not slow code allowed!
    1 - Slow code welcomed
*/

#if SLOW
#define Assert(expression, msg) if(!(expression)) { printf(msg); exit(-1); }
#else
#define Assert(expression, msg)
#endif


// TODO(jake): Should these always be 64-bit?
#define Kilobytes(value) ((value)*1024LL)
#define Megabytes(value) (Kilobytes(value)*1024LL)
#define Gigabytes(value) (Megabytes(value)*1024LL)
#define Terabytes(value) (Gigabytes(value)*1024LL)

#define ArrayCount(array) (sizeof(array) / sizeof((array)[0]))

#if INTERNAL
// TODO(jake): need to implement these
// internal void* debugPlatformReadEntireFile(char* filename);
// internal void debugPlatformFreeFileMemory(void* memory);
// internal bool32 debugPlatformWriteEntireFile(char* filename, 
//                                              uint32_t size_memory, 
//                                              void* memory);
#else
#endif

/*
  TODO(jake): Services that the platform layer provides to the game
*/

/*
  NOTE(jake): Services that the game provides to the platform layer.
  (this may expand in the future - sound on separate thread, etc.)
*/

// FOUR THINGS - timing, controller/keyboard input, bitmap buffer to use, sound buffer to use

// TODO(jake): In the future, rendering _specifically_ will become a three-tiered abstraction!!!

typedef struct OffscreenBuffer {
  int width;
  int height;
  int pitch;
  int bytes_per_pixel;
  void* memory;
} OffscreenBuffer;

typedef struct EngineMemory {
  uint64_t permanent_storage_size;
  uint64_t transient_storage_size;
  bool32 is_initialized;
  void* permanent_storage;
  void* transient_storage;
} EngineMemory;

typedef struct ButtonState {
  int32_t half_transition_count;
  bool32 is_down_ended;
} ButtonState;


typedef struct ControllerInput {
  float start_x;
  float start_y;
  union {
    ButtonState buttons[4];
    struct {
      ButtonState key_w;
      ButtonState key_a;
      ButtonState key_s;
      ButtonState key_d;
    };
  };
} ControllerInput;

typedef struct EngineInput {
  ControllerInput controller;
} EngineInput;


typedef struct EngineClock {
  // TODO(jake): insert clock values here
} EngineClock;

internal void reallocateBuffer(OffscreenBuffer* buffer, int width, int height);

internal void updateAndRender(EngineInput* input, EngineMemory* memory, OffscreenBuffer* buffer);

//
// 
// 

typedef struct EngineState {
  int green_offset;
  int blue_offset;
} EngineState;