(
//available @ http://sccode.org/1-5eR
//cmd-enter to run, esc to close

var height=20, width=30,
body = (1..6),
size = body.size,
grow_inc = 2, //get 1 food = +2 size
framerate = 16,
dir = \east;

//snake + board are represented as 2D array,
//0 = empty space
//positive integers = snake body, value represents
//number of frames until snake segment disappears
//e.g. 6-segment snake heading east looks like:
// [0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0]
var board = (0!(height*width)).clump(width);

//current position of snake "head"
var pos = round(height/2) @ (size + 1);

//amount/direction to shift on each frame
var shift = 0 @ 1;

//for creating snake food
var foodpos, foodcolor, tryfoodpos;

//gui
var win, u, deadbox;

//functions that handle snake crash and food generation
var crash, makefood;

Window.closeAll;

makefood = {

	//colorful snacks
	foodcolor = Color.rand(0.25,1.0);
	foodpos = nil;

	//make sure food isn't placed on snake body
	while(
		{foodpos == nil},
		{
			tryfoodpos = rand(height) @ rand(width);
			if(
				//food generation only successful if blank space is chosen
				board[tryfoodpos.x][tryfoodpos.y] == 0,
				{foodpos = tryfoodpos.copy}
			);
		}
	);
};

win = Window.new("snake", Rect(
	Window.screenBounds.width/2-(width*10),
	Window.screenBounds.height/2-(height*10),
	width*20,height*20
), false, false).front;

u = UserView(win, win.view.bounds)
.background_(Color.gray(0.1));

//game over & score box, only visible when you crash
//(score = snake body size)
deadbox = StaticText(win, Rect(
	win.bounds.width/2 - 50,
	win.bounds.height/2 - 20,
	100, 40
))
.visible_(false)
.background_(Color.red(0.7))
.stringColor_(Color.gray(0.8))
.align_(\center);

//when crash, stop animation and display game over & score
crash = {
	u.animate_(false);
	deadbox
	.string_("you died\nscore: "++size)
	.visible_(true);
};

//place snake body integers on 2D array
body.do({
	arg n,i;
	board[round(height/2)].put(2+i,n);
});

//generate a food location
makefood.();

//game animation handled by userview drawfunc
u.drawFunc_({

	//decrement board, lower bound at zero
	board = (board - 1).max(0);

	//adjust shift based on movement direction
	case
	{dir == \east} {shift = 0 @ 1}
	{dir == \west} {shift = 0 @ -1}
	{dir == \north} {shift = -1 @ 0}
	{dir == \south} {shift = 1 @ 0}
	{true} {nil};

	//new target position for snake head
	pos = pos + shift;

	if(
		//check for boundary collision, crash if so
		(pos.y >= width) || (pos.y < 0) ||
		(pos.x >= height) || (pos.x < 0),

		crash,

		{
			//if no boundary crash, check for self-collision, crash if so
			if(
				(board[pos.x][pos.y] > 0),

				crash,

				//if no collision, place snake head on board
				{board[pos.x][pos.y] = size}
			);
		}
	);

	//check if food was acquired
	if(
		pos == foodpos,
		{
			//get bigger
			size = size + grow_inc;
			board = board.deepCollect(2, {
				arg n;
				if (n!=0, {n + grow_inc}, {0})
			});

			//generate new food
			makefood.();
		}
	);

	//draw next frame
	board.do({
		arg row, j;
		row.do({
			arg val, i;
			Pen.fillColor_(Color.gray(
				//positive numbers are light gray (snake body)
				//0s are dark grey (game board background)
				(val>0).asInteger*0.6+0.1
			));
			Pen.addRect(Rect(i*20, j*20, 20, 20));
			Pen.fill;
		});
	});

	//draw food
	Pen.fillColor_(foodcolor);
	Pen.addRect(Rect(foodpos.y*20,foodpos.x*20, 20, 20));
	Pen.fill;
});

//userview updates snake direction in response to arrow keys
u.keyDownAction_({
	arg view, char, mod, uni, keycode;
	case
	{keycode == 123} {dir = \west}
	{keycode == 124} {dir = \east}
	{keycode == 125} {dir = \south}
	{keycode == 126} {dir = \north}
	{uni == 27} {u.animate_(false); win.close}
	{true} {nil};
});

//set framerate and start game
u.frameRate_(framerate);
u.animate_(true);
)