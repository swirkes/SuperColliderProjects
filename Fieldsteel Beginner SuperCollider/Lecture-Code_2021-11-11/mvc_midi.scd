(
var model, ctrl, view = (), win, actionFn;
MIDIdef.freeAll;
MIDIIn.connectAll;

model = (knob: 0!8, fader: 0!8, solo: 0!8, mute: 0!8,rec: 0!8);

ctrl = SimpleController(model);
[\knob,\fader,\solo,\mute,\rec].do({ |n|
	ctrl.put(n, {
		arg model, sym, index, val;
		{view[n][index].value_(val/127)}.defer;
		model.postln;
	});
});

actionFn = { //generic controller action — update model & inform views
	arg view, index, sym;
	var val = (view.value*127).round;
	model[sym].put(index, val);
	model.changed(sym, index, val);
};

win = Window("nanoKontrol2", Rect(100,100,800,250))
.onClose_({ ctrl.remove }).front;
win.view.decorator_(FlowLayout(win.view.bounds, 0@0, 0@0));

view[\topview] = View(win, 800@50).background_(Color.gray(0.25))
.decorator_(FlowLayout(Rect(0,0,800,50), 0@5, 0@0));

view[\bottomview] = 16.collect({ |i|
	var v = View(win, 50@200).background_(Color.gray(0.25));
	if(i.even)
	{v.decorator_(FlowLayout(Rect(0,0,50,200), 10@30, 0@20))}
	{v.decorator_(FlowLayout(Rect(0,0,50,200), 10@10, 0@0))};
});

view[\knob] = 8.collect({ |i|
	Knob(view[\topview], 100@40)
	.action_({ |v| actionFn.(v, i, \knob) });
});

view[\fader] = 8.collect({ |i|
	Slider(view[\bottomview][i*2+1], 30@180)
	.action_({ |v| actionFn.(v, i, \fader) });
});

[\solo,\mute,\rec].do({ |v|
	view[v] = 8.collect({ |i|
		Button(view[\bottomview][i*2], 30@30)
		.action_({ |btn| actionFn.(btn, i, v) })
		.font_(Font(Font.defaultSansFace, 16))
		.states_([
			[v.asString[0].toUpper],
			[v.asString[0].toUpper, Color.white, Color.red(0.9)]
		]);
	});
});

[
	[\fader, 0],
	[\knob, 16],
	[\solo, 32],
	[\mute, 48],
	[\rec, 64]
].do({ |n,i|
	MIDIdef.cc(n[0], {
		arg val, num;
		model[n.at(0)].put(num-n.at(1), val);
		model.changed(n.at(0), num-n.at(1), val);
	}, (n[1]..n[1]+7));
});
)