
# Deep link URI scheme

## URI Template:

```
pia.app?to=$lat;$lon;$level&limitations=$1;$2;$n
```

### lat

The WGS 84 latitude of the destination in decimal representation.
**Type**: double

### lon

The WGS 84 longitude of the destination in decimal representation.
**Type**: double

### level

The level or floor of the destination. 0 describes the level of the main entrance (usually ground level).
**Type**: integer

### limitations (optional)

A list of individual routing profile properties (stairs, elevator, ...) which are **accessible** to the user. Omitting this parameter or defining all properties means no restrictions.
**Type**:  semicolon separated list of pre-defined strings: `stairs`, `ramp`, `elevator`, `escalator`, `step`

## Example:

```
pia.app?to=52.13148;11.62455;2&limitations=elevator;escalator
```