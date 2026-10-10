/*
 * panner_node.c - Custom equal-power panning node for miniaudio
 *
 * Compiled as its own C translation unit; miniaudio's implementation lives in miniaudio_impl.c
 */

#include "panner_node.h"
#include <math.h>
#include <string.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* Forward declaration */
static void panner_node_process_pcm_frames(
    ma_node* pNode,
    const float** ppFramesIn,
    ma_uint32* pFrameCountIn,
    float** ppFramesOut,
    ma_uint32* pFrameCountOut
);

/* Node vtable */
static ma_node_vtable g_panner_node_vtable = {
    panner_node_process_pcm_frames,
    NULL,   /* No custom input frame count calculation needed */
    1,      /* 1 input bus (mono) */
    1,      /* 1 output bus (stereo) */
    0       /* Default flags */
};

/* Calculate equal-power gains from pan value */
static void panner_calculate_gains(float pan, float* left_gain, float* right_gain) {
    /* Map pan from [-1, 1] to angle [0, π/2] */
    float theta = (pan + 1.0f) * 0.25f * (float)M_PI;
    *left_gain = cosf(theta);
    *right_gain = sinf(theta);
}

/* Process callback - called from audio thread */
static void panner_node_process_pcm_frames(
    ma_node* pNode,
    const float** ppFramesIn,
    ma_uint32* pFrameCountIn,
    float** ppFramesOut,
    ma_uint32* pFrameCountOut
) {
    panner_node* pPanner = (panner_node*)pNode;
    const float* pFramesIn;
    float* pFramesOut;
    ma_uint32 frameCount;
    ma_uint32 iFrame;
    float target_pan;

    (void)pFrameCountIn;  /* Unused - we consume same number as output */

    if (*pFrameCountOut == 0) {
        return;
    }

    pFramesIn = ppFramesIn[0];   /* Mono input */
    pFramesOut = ppFramesOut[0]; /* Stereo output */
    frameCount = *pFrameCountOut;

    /* Check if target pan has changed (atomic load) */
    target_pan = panner_atomic_load_f32(&pPanner->target_pan);

    if (target_pan != pPanner->prev_pan && pPanner->smooth_samples_remaining == 0) {
        /* Start new interpolation */
        pPanner->smooth_samples_remaining = PANNER_SMOOTH_SAMPLES;
        pPanner->pan_increment = (target_pan - pPanner->current_pan) / PANNER_SMOOTH_SAMPLES;
        pPanner->prev_pan = target_pan;
    }

    /* Process frames */
    for (iFrame = 0; iFrame < frameCount; iFrame++) {
        float mono_sample = pFramesIn[iFrame];
        float left_gain, right_gain;

        /* Update pan if interpolating */
        if (pPanner->smooth_samples_remaining > 0) {
            pPanner->current_pan += pPanner->pan_increment;
            pPanner->smooth_samples_remaining--;

            /* Snap to target at end of interpolation */
            if (pPanner->smooth_samples_remaining == 0) {
                pPanner->current_pan = pPanner->prev_pan;
            }
        }

        /* Calculate and apply gains */
        panner_calculate_gains(pPanner->current_pan, &left_gain, &right_gain);

        pFramesOut[iFrame * 2 + 0] = mono_sample * left_gain;
        pFramesOut[iFrame * 2 + 1] = mono_sample * right_gain;
    }
}

/* Initialize a panner node */
ma_result panner_node_init(
    ma_node_graph* pNodeGraph,
    float initial_pan,
    const ma_allocation_callbacks* pAllocationCallbacks,
    panner_node* pPanner
) {
    ma_result result;
    ma_node_config nodeConfig;
    ma_uint32 inputChannels[1];
    ma_uint32 outputChannels[1];

    if (pPanner == NULL) {
        return MA_INVALID_ARGS;
    }

    memset(pPanner, 0, sizeof(*pPanner));  /* MA_ZERO_OBJECT is private to miniaudio's implementation */

    /* Clamp initial pan */
    if (initial_pan < -1.0f) initial_pan = -1.0f;
    if (initial_pan > 1.0f) initial_pan = 1.0f;

    /* Set up channel counts: mono in, stereo out */
    inputChannels[0] = 1;
    outputChannels[0] = 2;

    nodeConfig = ma_node_config_init();
    nodeConfig.vtable = &g_panner_node_vtable;
    nodeConfig.pInputChannels = inputChannels;
    nodeConfig.pOutputChannels = outputChannels;

    result = ma_node_init(pNodeGraph, &nodeConfig, pAllocationCallbacks, &pPanner->base);
    if (result != MA_SUCCESS) {
        return result;
    }

    /* Initialize pan state */
    panner_atomic_store_f32(&pPanner->target_pan, initial_pan);
    pPanner->prev_pan = initial_pan;
    pPanner->current_pan = initial_pan;
    pPanner->smooth_samples_remaining = 0;
    pPanner->pan_increment = 0.0f;

    return MA_SUCCESS;
}

/* Uninitialize a panner node */
void panner_node_uninit(
    panner_node* pPanner,
    const ma_allocation_callbacks* pAllocationCallbacks
) {
    if (pPanner == NULL) {
        return;
    }

    ma_node_uninit(&pPanner->base, pAllocationCallbacks);
}

/* Set the pan value (thread-safe, can be called from any thread) */
void panner_node_set_pan(panner_node* pPanner, float pan) {
    if (pPanner == NULL) {
        return;
    }

    /* Clamp pan to valid range */
    if (pan < -1.0f) pan = -1.0f;
    if (pan > 1.0f) pan = 1.0f;

    panner_atomic_store_f32(&pPanner->target_pan, pan);
}

/* Get the current target pan value (thread-safe) */
float panner_node_get_pan(const panner_node* pPanner) {
    if (pPanner == NULL) {
        return 0.0f;
    }

    return panner_atomic_load_f32(&pPanner->target_pan);
}
