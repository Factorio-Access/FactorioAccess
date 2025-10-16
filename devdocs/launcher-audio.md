# Audio Commands

The mod makes up unique ids (it already knows how to do this) and passes them out to the launcher.

Let's say it's `sound` as the command.  Since we are not dealing with localised strings, at least for now, we will make the body JSON.

EX:

```
sound 1 { ... }
```

Where 1 is pindex.

To allocate a sound the mod just starts using it.

we need 2 commands:

## Stop

```
{ "id": 5 }
```

Stop a sound if playing. If not playing, do nothing.

## Patch

```
{
   "id": 5,
   "subpath": "foo.ogg",
   "volumes:" {
      "left": 0.5,
      "right": 0.2,
   },
   "looping": false,
   -- 0.5 is twice as long, 2 is half as long.
   "playback_speed": 1.0,
}
```

The launcher updates these params to the audio library. The exception is looping: we will guarantee that the mod does not flip this after the first use of a sound.

That means that sound freeing is "if it's done, just drop it".

# Restarts

There are two cases to consider:

- The mod has been running in a steady state for a while
- The mod restarted, but with sounds playing

In the first case things are fine.  In the second case we get one of two things:

- Sounds which are already partway through that start from the beginning
- SOunds which we ask to stop that never started

In either case it's a small window with livable glitches, especially since most of our sounds will be short, and shutting down in the middle of combat is extremely rare.
