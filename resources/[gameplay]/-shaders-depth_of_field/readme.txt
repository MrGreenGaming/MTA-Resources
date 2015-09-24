Resource: Shader Depth of Field v0.0.6
Author: Ren712
Contact: knoblauch700@o2.pl

2013-11-22: If you experience reduced draw distance, update
your MTA to newest nightly version. Minimal version is: r5899
I have applied version check to (kind of) enforce that.

Update 0.0.6:
- Slightly changed the bluring method
- Added brightBlur variable - makes darker pixel get less blur
- Added some variables to get proper depth spread
- set MaxCut to 'unblur' the farthest bounds of the world (sky,sun etc..)
- Added MaxCutBlur variable to set blur level of sky.
Update 0.0.4:
-Added version check (due to current MTA bugfix)
Update 0.0.3:
-Layered effect - works with other full screen effects now.
-Switching the effect with /sDoF
-added a command /dxGetStatus

This resource adds a simple full screen effect.
What it does is create the depth of field effect, mostly
known in fps games - it blurs the parts of the screen that
show distant objects.

Works good with all the postprocess shaders.

The resource might not work on some older GFX (especially INTEL).
It is due to Zbuffer usage.

-- Reading depth buffer supported by:
-- NVidia - from GeForce 6 (2004)
-- Radeon - from 9500 (2002)
-- Intel - from G45 (2008)