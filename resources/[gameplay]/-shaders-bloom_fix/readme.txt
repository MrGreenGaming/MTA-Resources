Resource: Shader Bloom fix v0.6
Source: Original script on mta wiki
Modified by: Ren712
Mail: knoblauch700@o2.pl

Update:
-Fixed the bleeding edges
-Reconfigured the effect to be less intensive
-Added blur amount variable
-Layered effect - works with other full screen effects now.
-Switching the effect with /sBloom

This is essentially the bloom shader from shader examples.
I noticed that allot of the servers use that effect. Knowing
some of it's bugs - I decided to fix it a bit. Plus, it really
needed a switch. 

I was thinking about a new shader panel - decided that it will
control shader resources by events. So that was the main reason to
post it here.

That's it.