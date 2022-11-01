s.boot;

(
var window, slider, synth;
window = Window.new(bounds:Rect(100,100,300,300)).front;

synth = {
	arg cf=200;
	LPF.ar(Pulse.ar([100,101], mul:0.2), cf.varlag(0.1,-6));
}.play;

slider = Slider(window, Rect(25,25,250,25))
.action_({ |v|
	synth.set(\cf, v.value.linexp(0,1,150,10000));
});
)



(
//press x to enable/disable slider
Window.closeAll;
w = Window.new(bounds:Rect(100,100,500,200)).front;
w.acceptsMouseOver_(true);

w.view.keyDownAction_({ |view, char, mod, uni, keycode, key|
	if(char == $x)
	{v.enabled_(v.enabled.not.postln)};
});

v = Slider(w, Rect(25, 25, 25, 150))
.mouseEnterAction_({ |view|
	view.background_(Color(0, 0.7, 1))
})
.canFocus_(false)
.mouseLeaveAction_({ |view|
	view.background_(Color.gray(0.75))
});
b = Button(w, Rect(75, 25, 100, 100))
.states_([[\0], [\1]])
.font_(Font(Font.defaultSansFace, 50))
.canFocus_(false);
)



(
Window.closeAll;
w = Window.new(bounds:Rect(800,100,500,350))
.alwaysOnTop_(true).front;
w.view.decorator_(FlowLayout(w.view.bounds, 20@20, 10@10));
x = 10.collect({ |i|
	Slider(w, 37@150)
});
b = 40.collect({ |i|
	Button(w, 37@32)
	.states_([
		[i+1],
		[i+1, Color.white, Color.red(0.8)]
	]);
});
)

Point(3,5);

3@5;



(
Window.closeAll;

MIDIIn.connectAll;

MIDIdef.cc(\nano, {
	arg val, num;
	{ v.valueAction_(val/127) }.defer;
}, 0);

w = Window.new(bounds:Rect(100,100,500,200)).front;
v = Slider(w, Rect(25, 25, 25, 150));
)



(
Window.closeAll;
w = Window.new.alwaysOnTop_(true).front;
u = UserView(w, w.view.bounds)
.drawFunc_({ |view|
	Pen.width_(5);
	Pen.strokeColor_(Color.white);
	Pen.line(rrand(10,380)@rrand(10,380), rrand(10,380)@rrand(10,380));
	Pen.stroke;
})
.background_(Color.black);
)

u.refresh;

u.animate_(true);
u.animate_(false);
u.frameRate_(30);