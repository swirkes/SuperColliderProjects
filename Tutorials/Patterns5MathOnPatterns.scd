p = Pwhite(1,5,inf)*2; //a Pbinop

p.operator
p.a
p.b
p.asStream.nextN(5);

Pwhite(1,5,inf).asStream.nextN(4);

(Pwhite(1,5,inf)*2).asStream.nextN(4);

(Pwhite(1,5,inf)*0.25).asStream.nextN(4);

(Pwhite(1,5,inf)*Prand([-1,1],inf)).asStream.nextN(10);

(Pseq([10, 9, 8], 1) + Pseq([1, 2], 1)).do { |x| x.postln };

/*The binary operator adverb .x is supported with patterns. (See Adverbs for Binary Operators.) This adverb is like a nested loop: in streamA +.x streamB, the first value of streamA is added to every value of streamB in succession, then the second value of streamA is added to every streamB value, and so on. This is an easy way to transpose a pattern to different levels successively.*/
// Play a major-7th arpeggio, transposed to different scale degrees
// Pwhite is the transposer; Pseq is the chord
// The chord is like an "inner loop"
(
p = Pbind(
	\midinote, Pwhite(48,75,inf)+.x Pseq([0, 4, 7, 11, 7, 4],2),
	\dur, 0.125
).play;
)

// Arbitrary/custom operation: Turn each number into a two-digit hex string
Pwhite(0, 255, 20).collect({ |x| x.asHexString(2) }).do { |x| x.postln };

// Keep odd numbers in the result (which is now less than 20 items)
Pwhite(0, 255, 20).select({ |x| x.odd }).do { |x| x.postln };

// Throw out odd numbers in the result
Pwhite(0, 255, 20).reject({ |x| x.odd }).do { |x| x.postln };

// A flat stream becomes an array of 4-item arrays
Pwhite(0, 255, 20).clump(4).do { |x| x.postln };

    // a two-dimensional array
Array.fill(5, { Array.fill(4, { rrand(1, 5) }) });

    // a pattern reading that array in sequence
p = Pseq(Array.fill(5, { Array.fill(4, { rrand(1, 5) }) }), 1);

    // the pattern returns several arrays
p.do { |x| x.postln };

    // flattening the pattern returns a one-dimensional stream of numbers
p.flatten.do { |x| x.postln };

// Swing notes with Prorate
(
p = Pbind(
    \degree, Pseries(4, Pwhite(-2, 2, inf).reject({ |x| x == 0 }), inf).fold(-7, 11),
    \dur, Prorate(0.6, 0.5)    // actually yields 0.3, 0.2, 0.3, 0.2...
).play;
)

p.stop;

// play repeated notes with a different rhythmic value per new pitch
// using Pstutter
p = Pbind(
        // making 'n' a separate stream so that degree and dur can share it
    \n, Pwhite(3, 10, inf),
    \degree, Pstutter(Pkey(\n), Pwhite(-4, 11, inf)),
    \dur, Pstutter(Pkey(\n), Pwhite(0.1, 0.4, inf)),
    \legato, 0.3
).play;

p.stop;


// using Pfin / Pn
// Pn loops the Pbind infinitely
// Plazy builds a new Pbind for each iteration
// Pfin cuts off the Pbind when it's time for a new value

p = Pn(
    Plazy {
        Pbind(
            \degree, Pfin(rrand(3, 10), rrand(-4, 11)),
            \dur, rrand(0.1, 0.4)
        )
    },
    inf
).play;

p.stop;


// using Pclutch
// the rule is, when degree changes, dur should change also
// if Pdiff returns 0, degree has not changed
// so here, nonzero Pdiff values "connect" the clutch and allow a new dur to be generated
// otherwise the old one is held
p = Pbind(
    \degree, Pstutter(Pwhite(3, 10, inf), Pwhite(-4, 11, inf)),
    \dur, Pclutch(Pwhite(0.1, 0.4, inf), Pdiff(Pkey(\degree)).abs > 0),
    \legato, 0.3
).play;

p.stop;