s.options.maxLogins = 2;
s.reboot;
(
r = Server(
	\remote4,
	NetAddr("192.168.1.70", 57120),
	s.options
);
)
s.userSpecifiedClientID;
r.userSpecifiedClientID;

{SinOsc.ar(440, 0.2)}.play;

o = ServerOptions.new;
o.maxLogins = 8;
t = Server.remote(\remotely1, NetAddr("192.168.1.70", 57120), o, 1);
t.makeWindow
s.options.maxLogins = 8
t.addr = NetAddr("192.168.1.70", 57120);
t.reboot;

(
s.options.protocol = \tcp; // set to use tcp
s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 2; // set to correct number of clients
s.boot;
)

s.options.maxLogins = 8;
s.addr = NetAddr("192.168.1.70", 57120)
