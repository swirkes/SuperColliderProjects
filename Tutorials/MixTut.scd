{ [SinOsc.ar(440, 0, 0.5), SinOsc.ar(440, pi, 0.5)] }.plot
(
{var ampOsc;
	ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
	SinOsc.ar(440, 0, ampOsc);
}.plot
)

(
{var freq;
	freq = [1320, 880].choose;
	SinOsc.ar(freq, 0, 0.2);
}.play;
)

{ Pan2.ar(SinOsc.ar(300), SinOscFB.kr(1, 0.5)) }.plot;

{ PinkNoise.ar(0.5) + SinOsc.ar(440, 0.2) + Saw.ar(445, 0.2) }.plot;

{ Mix.new([SinOsc.ar(220, 0, 0.2), Saw.ar(260, 0.2)]).postln }.play;

(
{
	var a,b;
	a = [SinOsc.ar(300, 0, 0.2), Saw.ar(302, 0.2)];
	b = [SinOsc.ar(312, 0, 0.2), Saw.ar(303, 0.2)];
	Mix([a,b]).postln;
}.play
)

(
{
    var a, b;
    a = [SinOsc.ar(440, 0, 0.2), Saw.ar(662, 0.2)];
    b = [SinOsc.ar(442, 0, 0.2), Saw.ar(660, 0.2)];
    Mix([a, b]).postln;
}.play;
)

(
     var n = 8;
     { Mix.fill(n, { SinOsc.ar(500 + 20000.0.rand, 0, 1/n)})}.play;
)

(
    var n = 8;
    { Mix.fill(n, { SinOsc.ar(500 + 500.0.rand, 0, 1 / n) }) }.play;
)

{SinOsc.ar(20000, 0, 0.2)}.play


(
    var n = 8;
    {
        Mix.fill(n, { arg index;
            var freq;
            index.postln;
            freq = 440 + index;
            freq.postln;
            SinOsc.ar(freq , 0, 1 / n)
        })
    }.play;
)

{ PinkNoise.ar(0.2) + SinOsc.ar([440, 441], 0, 0.2) + Saw.ar(660, 0.2) }.scope;
