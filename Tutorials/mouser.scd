(
{
	var sig, freq, env;
	freq = XLine.kr(ExpRand(40, 4000),ExpRand(20, 4000), 3, doneaction:2);
	env = XLine.kr(ExpRand(0.01, 0.75), ExpRand(0.05, 1), ExpRand(0.3, 4), 4, doneAction:2);
	sig = Pulse.ar(freq) * env.dbamp;
}.play;
)

(
{
	var sig, env;
	env = EnvGen.kr(Env.new([0, 0.14, 0.56, 0.34, 0], [1, 0.5, 0.25, 1], 'lin'), doneAction:2);
	sig = SinOsc * env;
}.play;
)

Env.new(levels(0, 1, 0), times: [1, 1], curve.plot;

	{SinOscFB.ar(440,MouseX.kr(0,4))*0.1}.play

x =	{SinOscFB.ar(100*SinOscFB.ar(MouseY.kr(1,1000,'exponential'))+200,MouseX.kr(0.5pi,pi))*0.1}.play


	{ SinOscFB.ar([400,301], MouseX.kr(0,4),0.3); }.scope;