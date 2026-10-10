/* The one translation unit holding the implementations of miniaudio and its decoders (dr_wav, dr_flac, dr_mp3,
 * stb_vorbis). Order matters: stb_vorbis's header must be seen before miniaudio so miniaudio enables Vorbis support,
 * and its implementation must come after miniaudio. Their warnings are not ours to fix. */

/* Uninitialised-use warnings come from the optimiser after the push/pop region has been popped, so they need a TU-wide disable. */
#pragma warning(disable : 4701 4703)
#pragma warning(push, 0)

#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

#define DR_FLAC_IMPLEMENTATION
#include "dr_flac.h"

#define DR_MP3_IMPLEMENTATION
#include "dr_mp3.h"

#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#undef STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#pragma warning(pop)
