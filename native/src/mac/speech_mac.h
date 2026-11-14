#pragma once
// Mac-only additions to fa::speech (speech.h).
namespace fa::speech {
// A key went down in the game window. A screen reader cuts its own speech on a key press; the system voice has
// nobody else to, so it stops here. Does nothing while a screen reader speaks.
void key_pressed();
}  // namespace fa::speech
