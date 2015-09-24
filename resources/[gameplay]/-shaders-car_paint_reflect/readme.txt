Resource: Shader Car Paint reflect
Update 0.2.7
-The windshield effect is now in a single pass
-The effect uses up to all 4 pointlights for vehicle lighting (reapplied)
-Applied VS specular light for vehicles
-Changed the reflection fading method
-Reconfigured reflection effects
-Added 2 variable to determine reflection displacement settings
Update 0.2.5
-Changed the displacement method
Update 0.2.4
-Reapplied the gtasa fog for SM3 effect
Update 0.2.3
-Rewritten the effects. Applied a better reflection method
-Imported effect from car_paint_fix: skylight
-Added minZviewAngleFade variable

The reflection is based on screen source, giving an illusion 
of realtime reflection. Effect is similar to what is seen in ENB.  
It is applied to vehicle paint and windshields.
The effect requires (just as the carpaint shader) PS Model 2.0 GFX.
So it will run on almost anything.

Update:
-the effect uses up to all 4 pointlights for vehicle lighting
-added switching option (event and /sCarReflect)

have fun
Ren712

knoblauch700@o2.pl

Credits:
I'd like to thank Ccw for earlier support.
And diegofkda for bug reports.