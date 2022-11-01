s.boot;

b = Buffer.alloc(s, 512, 1, {arg buf;
	buf.chebyMsg([0.25,0.5,0.25], false)});

(
{
	Shaper.ar(
		b,
		SinOsc.ar(444, 0.5pi, Line.kr(0,1,6)),
		0.5
	)
}.scope;
)

b = Buffer.alloc(s, 1024, 1);
b.cheby([1, 0.5, 1, 0.125]);

(
{     var    sig = Shaper.ar(b, SinOsc.ar(440, 0, 0.4));
    sig ! 2
}.scope;
)

b.free;

b = Buffer.alloc(s, 1024, 1);

//size must be power of two plus 1
t = Signal.chebyFill(513,[1, 0.5, 1, 0.125]);

// linear function
t.plot

// t.asWavetableNoWrap will convert it to the official Wavetable format at next power of two size
b.sendCollection(t.asWavetableNoWrap);  // may also use loadCollection here

b.plot

(
{     var    sig = Shaper.ar(b, SinOsc.ar(440, 0, 0.4));
    sig ! 2
}.scope;
)

b.free;

b = Buffer.alloc(s, 1024, 1);

// or, for an arbitrary transfer function, create the data at 1/2 buffer size + 1
t = Signal.fill(513, { |i| i.linlin(0.0, 512.0, -1.0, 1.0) });

// linear function
t.plot

// t.asWavetable will convert it to the official Wavetable format at twice the size
b.sendCollection(t.asWavetableNoWrap);  // may also use loadCollection here

// shaper has no effect because of the linear transfer function
(
{     var    sig = Shaper.ar(b, SinOsc.ar(440, 0, 0.4));
    sig ! 2
}.scope;
)


// now for a twist
(
a = Signal.fill(256, { |i|
    var t = i/255.0;
    t + (0.1 * (max(t, 0.1) - 0.1) * sin(2pi * t * 80 + sin(2pi * 25.6 * t)))
})
);

a.plot

d = (a.copy.reverse.neg) ++(Signal[0])++ a;

d.plot

d.size    //must be buffer size/2 + 1, so 513 is fine

b.sendCollection(d.asWavetableNoWrap);  // may also use loadCollection here

b.plot // wavetable format!

// test shaper
(
{
    Shaper.ar(
        b,
        SinOsc.ar(440, 0.5, Line.kr(0,0.9,6))
    )
}.scope
)

(
var randomNumbers, histogram, maxValue = 500.0, numVals = 10000, numBins = 500;

randomNumbers = Array.fill(numVals, { maxValue.linrand; });
histogram = randomNumbers.histo(numBins, 0, maxValue);
histogram.plot("histogram for linrand 0 - " ++ maxValue);
)

{ rrand(SinOsc.ar(0.1), SinOsc.ar(0.42)) * 0.1 }.play

{ coin(SinOsc.ar(0.1)) * 0.1 }.play