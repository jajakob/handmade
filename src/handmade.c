#include "handmade.h"


internal void renderPlayer(OffscreenBuffer* buffer, 
                           int x_pos, int y_pos) {
  uint8_t* end_of_buffer = (uint8_t*)buffer->memory
                         + buffer->pitch * buffer->height;
  int bpp = buffer->bytes_per_pixel;
  uint32_t color = 0xFFFFFFFF;                      
  int top = y_pos;
  int bottom = y_pos + 10;
  for (int x = x_pos; x < x_pos + 10; ++x) {
    uint8_t* pixel = (uint8_t*)buffer->memory + x * bpp + top * buffer->pitch;
    for (int y = top; y < bottom; ++y) {
      if ((pixel >= (uint8_t*)buffer->memory) 
          && ((pixel+bpp) <= end_of_buffer)) {
        *(uint32_t*)pixel = color;
      }
      pixel += buffer->pitch;
    }
  }
}

internal void renderWeirdGradient(OffscreenBuffer* buffer, 
                                  int x_offset, int y_offset) {
  uint8_t* row = (uint8_t*) buffer->memory;
  for (int y = 0; y < buffer->height; y++) {   
      
      uint32_t* pixel = (uint32_t*) row;

      for (int x = 0; x < buffer->width; x++) {
          uint8_t blue = x + x_offset;
          uint8_t green = y + y_offset;
          // RGBA -> ABGR
          *pixel++ = (255 << 24) | (blue << 16) | (green << 8);
      }
      row += buffer->pitch;
  }
}

internal void reallocateBuffer(OffscreenBuffer* buffer, int width, int height) {
  if (buffer->memory)
      free(buffer->memory);
  buffer->bytes_per_pixel = 4; // rgba
  buffer->width = width;
  buffer->height = height;
  buffer->pitch = buffer->bytes_per_pixel * width;
  buffer->memory = malloc(buffer->pitch * height);
}


internal void updateAndRender(EngineInput* input, EngineMemory* memory, 
                              OffscreenBuffer* buffer) {

  Assert(sizeof(EngineState) <= memory->permanent_storage_size, "updateAndRender: assert\n");

  ControllerInput* controller = &input->controller;
  if (controller->key_d.is_down_ended) {
    controller->start_x++;
  }
  if (controller->key_w.is_down_ended) {
    controller->start_y--;
  }
  if (controller->key_a.is_down_ended) {
    controller->start_x--;
  }
  if (controller->key_s.is_down_ended) {
    controller->start_y++;
  }


  EngineState* engine_state = (EngineState*)memory->permanent_storage;
  if (!memory->is_initialized) {
    engine_state->blue_offset = 0;
    engine_state->green_offset = 0;
    memory->is_initialized = true;
  }
  engine_state->blue_offset += 1;
  renderWeirdGradient(buffer, 
                      engine_state->blue_offset, 
                      engine_state->green_offset);
  renderPlayer(buffer, controller->start_x, controller->start_y);
}