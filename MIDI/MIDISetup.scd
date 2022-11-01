MIDIClient.init
MIDIClient.sources
MIDIIn.connect(1, MIDIClient.sources.at(1));

(
SynthDef("sik-goo", { |out, freq = 440, formfreq = 100, gate = 0.0, bwfreq = 800|
    var x;
    x = Formant.ar(
        SinOsc.kr(0.02, 0, 10, freq),
        formfreq,
        bwfreq
    );
    x = EnvGen.kr(Env.adsr, gate, Latch.kr(gate, gate)) * x;
    Out.ar(out, x);
}).add;
)

x = Synth("sik-goo");

//set the action:
(
~noteOn = {arg src, chan, num, vel;
    x.set(\freq, num.midicps / 4.0);
    x.set(\gate, vel / 200 );
    x.set(\formfreq, vel / 127 * 1000);
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = { arg src,chan,num,vel;
    x.set(\gate, 0.0);
};
MIDIIn.addFuncTo(\noteOff, ~noteOff);

~bend = { arg src,chan,val;
    //(val * 0.048828125).postln;
    x.set(\bwfreq, val * 0.048828125 );
};
MIDIIn.addFuncTo(\bend, ~bend);
)

//cleanup
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\bend, ~bend);





(
SynthDef("funk",{ | out, freq = 700, amp = 0.2, gate = 1, cutoff = 20000, rez = 1, lfospeed = 0 |
    var e, x, env, range, filterfreq;
    e = Env.new([0, 0.1, 0.1, 0], [0, 0.1, 0.1], 'linear', 2);
    env = Env.adsr(0.3,1,1,1);
    range = cutoff -1;
    filterfreq = SinOsc.kr(lfospeed,0, range, cutoff).abs;
    x = RLPF.ar(Mix.ar([
            Mix.arFill(2, {Saw.ar(freq *2 + 0.2.rand2, amp)}),
            Mix.arFill(2, {Saw.ar(freq *4+ 0.2.rand2, amp)})
        ]),
        EnvGen.kr(env,gate)*filterfreq,
        rez);
    Out.ar(out, x * EnvGen.kr(e, gate, doneAction: Done.freeSelf))
}).add;

SynthDef("strings", { |out, freq = 700, amp = 0.2, gate = 1|
    var x, enve;
    enve = Env.new([0, 0.1, 0.1, 0], [2, 0.1, 1], 'linear', 2);
    x = RLPF.ar(Mix.ar([
            Mix.arFill(2, {Saw.ar(freq +2.rand2,0.6)}),
            Mix.arFill(2, {Saw.ar(freq *0.5 + 2.rand2,0.6)})
        ]),
        6000,1);
    Out.ar(out, x * EnvGen.kr(enve, gate, doneAction: Done.freeSelf))
}).add;
)

(
var keys, cutspec, cutbus, rezspec, rezbus, lfospec, lfobus;
keys = Array.newClear(128);

MIDIClient.init;
MIDIIn.connect(1, MIDIClient.sources.at(1));

g = Group.new;

cutspec = ControlSpec(100,10000,\linear,0.001);
cutbus = Bus.new(\control,1,1,s);
cutbus.value = 10000;

rezspec = ControlSpec(1,0,\linear,0.001);
rezbus = Bus.new(\control,2,1,s);
rezbus.value = 1.0;

lfospec = ControlSpec(0,50,\linear,0.001);
lfobus = Bus.new(\control,3,1,s);

~control = {arg src, chan, num, val;
    if(num == 1,{
        rezbus.value = rezspec.map(val/127.0);
    });
    if(num == 7,{
        lfobus.value = lfospec.map(val/127.0).postln;
    });
};
MIDIIn.addFuncTo(\control, ~control);

~bend = {arg src, chan, val;
    cutbus.value = cutspec.map(val/16383.0);
};
MIDIIn.addFuncTo(\bend, ~bend);

~noteOn = {arg src, chan, num, vel;
    var node;
    if(num < 60, {
        node = Synth.tail(g, "funk", [\freq, num.midicps, \amp, vel/255]);
        node.map("cutoff",1,"rez",2,"lfospeed",3);
//        node = Synth.basicNew("funk",s);
//        s.sendBundle(nil,
//            node.addToTailMsg(g,[\freq, num.midicps, \amp, vel/255]),
//            node.mapMsg("cutoff",1,"rez",2,"lfospeed",3)
//        );
        keys.put(num, node)
    },{
        node = Synth.tail(g, "strings", [\freq, num.midicps, \amp, vel/255]);
        keys.put(num, node)
    });
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = {arg src, chan, num, vel;
    var node;
    node = keys.at(num);
    if (node.notNil, {
        keys.put(num, nil);
        s.sendMsg("/n_set", node.nodeID, "gate", 0);
        // or node.release
        // then free it ... or get the NodeWatcher to do it
    });
};
MIDIIn.addFuncTo(\noteOff, ~noteOff);
)

//cleanup
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\control, ~control);
MIDIIn.removeFuncFrom(\bend, ~bend);