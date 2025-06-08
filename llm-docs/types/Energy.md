# Energy

Specifies an amount of electric energy in joules, or electric energy per time in watts.

Internally, the input in `Watt` or `Joule/second` is always converted into `Joule/tick`, where 1 second is equal to 60 ticks. This means it uses the following formula: `Power in Joule/tick = Power in Watt / 60`. See [Power](https://wiki.factorio.com/Units#Power).

Supported Multipliers:

- `k`: 10^3, or 1 000

- `M`: 10^6

- `G`: 10^9

- `T`: 10^12

- `P`: 10^15

- `E`: 10^18

- `Z`: 10^21

- `Y`: 10^24

- `R`: 10^27

- `Q`: 10^30

