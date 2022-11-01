s.meter
(
x = {
	arg pan=0;
	var sig, amp;
	amp = SinOsc.kr([7, 1]).range(0,1);
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

x.set(\pan, -1);
x.free

(
y = {
	arg pan=0;
	var sig, amp;
	amp = SinOsc.kr(7).range(0,1);
	sig = SinOsc.ar(300);
	sig = Pan2.ar(sig * amp, pan);
}.play;
)

y.set(\pan, -1);
y.play;
