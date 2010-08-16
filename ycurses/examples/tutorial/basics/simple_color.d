import ncurses;
version(Tango)
{
  import tango.stdc.stdio: printf;
}
else
{
  import std.c.stdio: printf;
}

int main(char[][] args)
{	initscr();			/* Start curses mode 		*/
	if(has_colors() == false)
	{	endwin();
		printf("Your terminal does not support color\n");
		return 1;
	}
	start_color();			/* Start color 			*/
	init_pair(1, COLOR_RED, COLOR_BLACK);

	attron(COLOR_PAIR(1));
	print_in_middle(stdscr, LINES / 2, 0, 0, "Viola !!! In color ...");
	attroff(COLOR_PAIR(1));
    	getch();
	endwin();

        return 0;
}
void print_in_middle(WINDOW *win, int starty, int startx, int width, char[] string)
{	int length, x, y;
	float temp;

	if(win == null)
		win = stdscr;
	getyx(win, y, x);
	if(startx != 0)
		x = startx;
	if(starty != 0)
		y = starty;
	if(width == 0)
		width = 80;

	length = string.length;
	temp = (width - length)/ 2;
	x = startx + cast(int)temp;
	mvwprintw(win, y, x, "%s", (string~'\0').ptr);
	refresh();
}

