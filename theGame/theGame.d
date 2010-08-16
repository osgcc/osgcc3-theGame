module theGame;

import tango.stdc.stringz;
import tango.math.Math;
import ncurses;
import map;
import enemies;
import globals;
import tango.core.Thread;
import player;
import items;
import scoreboard;
import tango.io.Stdout;

Map dungeon;
int currentRoomX;
int currentRoomY;
int currentFloor;
Player hero;
WINDOW* currentRoom, sidebox, messageBox, hud, help;
bool showHelp;

struct animationPiece
{
	int deltaX;
	int deltaY;
	wchar symbol;
}

void main()
{
	int y;
	int x;
	dungeon = new Map();
	hero = new Player(5,5);
	showHelp = false;
	
	initscr();
	noecho();
	cbreak();
	start_color();
	curs_set(0);
	
	currentRoom = newwin(15,20,2,2);
	sidebox = newwin(30,50,2,25);
	messageBox = newwin(2,80,0,0);
	hud = newwin(10,20,18,2);
	
	currentRoomY = dungeon.startPositionX;
	currentRoomX = dungeon.startPositionY;
	hero.x_pos = 10;
	hero.y_pos = 7;
	
	wprintw(messageBox," Welcome to the game. Clear out all the monsters to win.");
	wrefresh(messageBox);
	
	printScreen();
	
	char input;
	int count = 0;
	int monsterSpeed = 25000;
	
	wtimeout(currentRoom,0);
	
	while(1)
	{
		input = wgetch(currentRoom);
		
		getyx(currentRoom,y,x);
		
		switch(input)
		{
			case 'h':
				playerMove(y,x-1,WEST);
				break;
			case 'j':
				playerMove(y+1,x,SOUTH);
				break;
			case 'k':
				playerMove(y-1,x,NORTH);
				break;
			case 'l':
				playerMove(y,x+1,EAST);
				break;
			case 'q':
				goto end;
			case 'p':
				pickUpItem(y,x);
				break;
			case 'u':
				useItem();
				break;
			case ' ':
				animateSwordSwing(false);
				break;
			case 'd':
				dropItem();
				break;
			case 's':
				animateSwordSwing(true);
				break;
			case '?':
				showHelp = !showHelp;
				break;
			default:
				break;
		}
		
		if(count == monsterSpeed)
		{
			for(int i = 0; i < dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom.length; i++)
			{
				monsterMove(dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom[i]);
			}
			count = 0;
		}
		else
		{
			count++;
		}
		
		printScreen();
		
		if(hero.hp <= 0)
		{
			update_scoreboard(hero.score);
			werase(messageBox);
			wprintw(messageBox, "You died loser!!! You got %d points. Hit any key to continue.",hero.score);
			wrefresh(messageBox);
			wtimeout(currentRoom,360000);
			input = wgetch(currentRoom);
			goto end;
		}
		
		if(dungeon.totalEnemies == 0)
		{
			update_scoreboard(hero.score);
			werase(messageBox);
			wprintw(messageBox, "You won!!! You got %d points. Hit any key to continue.",hero.score);
			wrefresh(messageBox);
			wtimeout(currentRoom,360000);
			input = wgetch(currentRoom);
			goto end;
		}
	}	
	
	end:
			
	werase(currentRoom);
	werase(messageBox);
	werase(sidebox);
	wrefresh(currentRoom);
	wresize(currentRoom, 20, 50);
	wprintw(currentRoom, toStringz(print_scores()));
	wrefresh(currentRoom);
	wprintw(messageBox, "Press any key to exit.");
	wrefresh(messageBox);
	input = wgetch(currentRoom);
	wrefresh(sidebox);
	
	endwin();
}

void showInventory()
{
	werase(sidebox);
	wprintw(sidebox, "Inventory\n");
	wprintw(sidebox,"%s",toStringz(hero.print_inventory));
	wrefresh(sidebox);
}

void dropItem()
{
	werase(messageBox);
	wprintw(messageBox, "What would you like to drop? %s", toStringz(hero.print_inventory_symbols));
	wrefresh(messageBox);
	char[] errorMessage = "";
	char input = wgetch(messageBox);
	if(input >= 'a' && input <= 'z')
	{
		Item foo = hero.discard(input - 'a');
		if(foo !is null)
			dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom ~= foo;
		else
			errorMessage = "Cannot drop what is equipped.";
	}
	werase(messageBox);
	wprintw(messageBox,toStringz(errorMessage));
	wrefresh(messageBox);
}

void useItem()
{
	werase(messageBox);
	wprintw(messageBox, "What would you like to use? %s", toStringz(hero.print_inventory_symbols));
	wrefresh(messageBox);
	char input = wgetch(messageBox);
	char[] errorMessage = "";
	if(input >= 'a' && input <= 'z')
	{
		if(!hero.use_item(input - 'a'))
			errorMessage = "Cannot equip two swords or armors";
	}
	werase(messageBox);
	wprintw(messageBox,toStringz(errorMessage));
	wrefresh(messageBox);
}

void pickUpItem(int y, int x)
{
	for(int i = 0; i < dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom.length; i++)
	{
		Item currentItem = dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom[i];
		if(currentItem.y_pos == y && currentItem.x_pos == x)
		{
			if(hero.pick_up(currentItem))
				dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom = dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom[0 .. i]~dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.itemsInRoom[i+1 .. $];
		}
	}
}

void animate(animationPiece piece, WINDOW* win, coord homePosition, float sleepTime, bool continuous)
{
	if(!continuous)
		printScreen;
	wrefresh(win);
	wmove(win,homePosition.y+piece.deltaY, homePosition.x+piece.deltaX);
	wprintw(win, "%c", piece.symbol);
	wmove(win,homePosition.y, homePosition.x);
	wrefresh(win);
	Thread.sleep(sleepTime);
}

void animateSwordSwing(bool roundHouse)
{
	direction foo = hero.dir;
	coord[] swipeLocations;
	coord newCoord, heroCoord;
	animationPiece[8] fullAnimation;
	
	heroCoord.x = hero.x_pos;
	heroCoord.y = hero.y_pos;
	
	fullAnimation[0].deltaY = -1;
	fullAnimation[0].deltaX = -1;
	fullAnimation[0].symbol = '\\';
	fullAnimation[1].deltaY = -1;
	fullAnimation[1].deltaX = 0;
	fullAnimation[1].symbol = '|';
	fullAnimation[2].deltaY = -1;
	fullAnimation[2].deltaX = 1;
	fullAnimation[2].symbol = '/';
	fullAnimation[3].deltaY = 0;
	fullAnimation[3].deltaX = 1;
	fullAnimation[3].symbol = '-';
	fullAnimation[4].deltaY = 1;
	fullAnimation[4].deltaX = 1;
	fullAnimation[4].symbol = '\\';
	fullAnimation[5].deltaY = 1;
	fullAnimation[5].deltaX = 0;
	fullAnimation[5].symbol = '|';
	fullAnimation[6].deltaY = 1;
	fullAnimation[6].deltaX = -1;
	fullAnimation[6].symbol = '/';
	fullAnimation[7].deltaY = 0;
	fullAnimation[7].deltaX = -1;
	fullAnimation[7].symbol = '-';
	
	if(roundHouse)
	{
		foreach(animationPiece piece; fullAnimation)
		{
			newCoord.y = hero.y_pos+piece.deltaY;
			newCoord.x = hero.x_pos+piece.deltaX;
			swipeLocations ~= newCoord;
			animate(piece, currentRoom, heroCoord, .2, false);
		}
	}
	else
	{
		if(foo == NORTH)
		{
			foreach(animationPiece piece; fullAnimation[0..3])
			{
				newCoord.y = hero.y_pos+piece.deltaY;
				newCoord.x = hero.x_pos+piece.deltaX;
				swipeLocations ~= newCoord;
				animate(piece, currentRoom, heroCoord, .2, false);
			}
		}
		else if(foo == EAST)
		{
			foreach(animationPiece piece; fullAnimation[2..5])
			{
				newCoord.y = hero.y_pos+piece.deltaY;
				newCoord.x = hero.x_pos+piece.deltaX;
				swipeLocations ~= newCoord;
				animate(piece, currentRoom, heroCoord, .2, false);
			}
		}
		else if(foo == WEST)
		{
			foreach(animationPiece piece; fullAnimation[6..$]~fullAnimation[0])
			{
				newCoord.y = hero.y_pos+piece.deltaY;
				newCoord.x = hero.x_pos+piece.deltaX;
				swipeLocations ~= newCoord;
				animate(piece, currentRoom, heroCoord, .2, false);
			}
		}
		else
		{
			foreach(animationPiece piece; fullAnimation[4..7])
			{
				newCoord.y = hero.y_pos+piece.deltaY;
				newCoord.x = hero.x_pos+piece.deltaX;
				swipeLocations ~= newCoord;
				animate(piece, currentRoom, heroCoord, .2, false);
			}
		}
	}
	foreach(coord currentCoord; swipeLocations)
	{
		for(int i = 0; i < dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom.length; i++)
		{
			Enemy mob = dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom[i];
			if(mob.x_pos == currentCoord.x && mob.y_pos == currentCoord.y)
			{
				double dmg =  hero.attack(mob);
				if(mob.hp <= 0)
				{
					dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom = dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom[0 .. i]~dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.enemiesInRoom[i+1 .. $];
					dungeon.totalEnemies--;
					werase(messageBox);
					wprintw(messageBox,"You killed a %s",toStringz(mob.name));
					wrefresh(messageBox);
				}
			}
		}
	}
}

void showHud()
{
	werase(hud);
	wprintw(hud, "Health: %.2f/%.0f\nOffense: %d\nDefense: %d\nPress '?' for help.", hero.hp, hero.maxhp, hero.power, hero.defense);
	wrefresh(hud);
}

void showHelpBox()
{
	werase(sidebox);
	wprintw(sidebox, toStringz("Commands\n" ~
							"'h,j,k,l' move\n" ~
							"'p' pick up item\n" ~
							"' ' swing sword\n" ~
							"'s' roundhouse sword swing\n" ~
							"'d' drop an item\n" ~
							"'u' use item\n" ~
							"'q' quit\n" ~
							"'?' this help\n" ~
							"\n" ~
							"There seems to be some confusion about equipping and unequipping items. You use an equipped item to unequip it and you use an unequipped item to equip it."));
	wrefresh(sidebox);
}

void printScreen()
{
	werase(currentRoom);
	wprintw(currentRoom, "%s",toStringz(dungeon.globalMap[currentRoomY][currentRoomX].toString()));
	wmove(currentRoom,hero.y_pos,hero.x_pos);
	wprintw(currentRoom, "%c", hero.symbol);
	wmove(currentRoom,hero.y_pos,hero.x_pos);
	wrefresh(currentRoom);
	if(showHelp)
		showHelpBox();
	else
		showInventory();
	showHud();
}

void monsterMove(Enemy mob)
{
	int x = mob.x_pos;
	int y = mob.y_pos;
	
	int totalDistanceToPlayer = abs(x - hero.x_pos) + abs(y - hero.y_pos);
	int distanceForNORTH = abs(x - hero.x_pos) + abs(y-1 - hero.y_pos);
	int distanceForEAST = abs(x+1 - hero.x_pos) + abs(y - hero.y_pos);
	int distanceForWEST = abs(x-1 - hero.x_pos) + abs(y - hero.y_pos);
	int distanceForSOUTH = abs(x - hero.x_pos) + abs(y+1 - hero.y_pos);
	
	int minVal = min(distanceForNORTH, distanceForEAST, distanceForWEST, distanceForSOUTH);
	
	if(minVal == distanceForNORTH)
		y--;
	else if(minVal == distanceForEAST)
		x++;
	else if(minVal == distanceForWEST)
		x--;
	else
		y++;
	
	if(dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.floorplan[y][x] == '.')
	{
		if(hero.x_pos == x && hero.y_pos == y)
		{
			mob.attack(hero);
		}
		else
		{
			mob.move(y,x);
		}
	}
}

void playerMove(int y, int x, direction way)
{
	if(dungeon.globalMap[currentRoomY][currentRoomX].associatedRoom.floorplan[y][x] == '.')
	{
		if(way != hero.dir)
		{
			hero.change_direction(way);
		}
		else
		{
			if(x == 0 || x == 19)
			{
				if(way == EAST)
				{
					if(currentRoomX != 4)
					{
						currentRoomX++;
						hero.x_pos = 1;
					}
				}
				else
				{
					if(currentRoomX != 0)
					{
						currentRoomX--;
						hero.x_pos = 18;
					}
				}
			}
			else if(y == 0 || y == 14)
			{
				if(way == NORTH)
				{
					if(currentRoomY != 0)
					{
						currentRoomY--;
						hero.y_pos = 13;
					}
				}
				else
				{
					if(currentRoomY != 4)
					{
						currentRoomY++;
						hero.y_pos = 1;
					}
				}
			}
			else
			{
				hero.y_pos = y;
				hero.x_pos = x;
			}
		}
	}
}
