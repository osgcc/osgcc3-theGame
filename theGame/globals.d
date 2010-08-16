module globals;

enum direction{NORTH, EAST, WEST, SOUTH};

struct coord
{
	int x;
	int y;
}

alias direction.NORTH NORTH;
alias direction.EAST EAST;
alias direction.WEST WEST;
alias direction.SOUTH SOUTH;
