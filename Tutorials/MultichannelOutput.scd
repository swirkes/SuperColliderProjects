s.boot;
s.meter;
// one channel
{ Blip.ar(800,4,0.1) }.play;

// two channels
{ [ Blip.ar(800,4,0.1), WhiteNoise.ar(0.1) ] }.play;

// look at the outputs of Pan2:
Pan2.ar(PinkNoise.ar(0.1), FSinOsc.kr(3)).dump;
​
play({ Pan2.ar(PinkNoise.ar(0.1), FSinOsc.kr(1)); });

"open -a 'Audio MIDI Setup'".unixCmd;

