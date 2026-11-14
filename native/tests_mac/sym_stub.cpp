// layout.cpp resolves recipe functions through fa::sym; the tests drive the decoder directly instead.
#include "sym.h"

namespace fa::sym {
void* addr(const char*) { return nullptr; }
}  // namespace fa::sym
