module map;

import enemies;
import items;
import tango.math.random.Kiss;
import tango.io.Stdout;

struct room
{
	Enemy[] enemiesInRoom;
	Item[] itemsInRoom;
	char[][15] floorplan;
	int y;
	int x;
}

struct globalMapSpace
{
	int visited;
	room associatedRoom;
	
	char[] toString()
	{
		char[] returnString;
		
		for(int i = 0; i < 15; i++)
		{
			returnString = returnString ~ associatedRoom.floorplan[i];
		}
		
		for(int i = 0; i < associatedRoom.itemsInRoom.length; i++)
		{
			char symbol = associatedRoom.itemsInRoom[i].symbol;
			int loc = (associatedRoom.itemsInRoom[i].y_pos)*20+associatedRoom.itemsInRoom[i].x_pos;
			returnString[loc] = symbol;
		}
		
		for(int i = 0; i < associatedRoom.enemiesInRoom.length; i++)
		{
			char symbol = associatedRoom.enemiesInRoom[i].symbol;
			int loc = (associatedRoom.enemiesInRoom[i].y_pos)*20+associatedRoom.enemiesInRoom[i].x_pos;
			returnString[loc] = symbol;
		}
		
		return returnString;
	}
}

class Map
{
	globalMapSpace[5][5] globalMap;
	int startPositionX = -1;
	int startPositionY = -1;
	int totalEnemies = 0;
	
	this()
	{
		generateGlobalMap();
		countEnemies();
	}
	
	void generateGlobalMap()
	{
		for(int i = 0; i < 5; i++)
		{
			for(int j = 0; j < 5; j++)
			{
				switch(Kiss.instance.natural(3))
				{
					case 0:
					case 1:
						globalMap[i][j].visited = 0;
						break;
					case 2:
						globalMap[i][j].visited = 2;
						break;
					default:
						break;
				}
			}
		}
		for(int i = 0; i < 5; i++)
		{
			for(int j = 0; j < 5; j++)
			{
				if(globalMap[i][j].visited == 0)
				{
					if(startPositionX == -1)
					{
						startPositionX = i;
						startPositionY = j;
					}
					globalMap[i][j].associatedRoom = generateRoom(i,j);
				}
			}
		}
	}
	
	room generateRoom(int y, int x)
	{
		room newRoom;
		
		newRoom.y = y;
		newRoom.x = x;
		
		newRoom.enemiesInRoom.length = Kiss.instance.natural(6);
		
		for(int i = 0; i < newRoom.enemiesInRoom.length; i++)
		{
			newRoom.enemiesInRoom[i] = availableEnemies[Kiss.instance.natural($)](Kiss.instance.natural(13)+1,Kiss.instance.natural(18)+1);
		}
		
		newRoom.itemsInRoom.length = Kiss.instance.natural(3);
		
		for(int i = 0; i < newRoom.itemsInRoom.length; i++)
		{
			newRoom.itemsInRoom[i] = availableItems[Kiss.instance.natural($)](Kiss.instance.natural(13)+1,Kiss.instance.natural(18)+1);
		}
		
		if(y != 0 && globalMap[y-1][x].visited == 0)
		{
			newRoom.floorplan[0] = "+--------.---------+";
		}
		else
		{
			newRoom.floorplan[0] = "+------------------+";
		}
		for(int i = 1; i < 14; i++)
		{
			newRoom.floorplan[i].length = 20;
			
			if(i == 7)
			{
				if(x != 0 && globalMap[y][x-1].visited == 0)
				{
					newRoom.floorplan[i][0] = '.';
				}
				else
				{
					newRoom.floorplan[i][0] = '|';
				}
				if(x != 4 && globalMap[y][x+1].visited == 0)
				{
					newRoom.floorplan[i][19] = '.';
				}
				else
				{
					newRoom.floorplan[i][19] = '|';
				}
			}
			else
			{
				newRoom.floorplan[i][0] = '|';
				newRoom.floorplan[i][19] = '|';
			}
			
			newRoom.floorplan[i][1..19] = '.';
			
		}
		if(y != 4 && globalMap[y+1][x].visited == 0)
		{
			newRoom.floorplan[14] = "+--------.---------+";
		}
		else
		{
			newRoom.floorplan[14] = "+------------------+";
		}
		
		return newRoom;
	}
	
	void countEnemies()
	{
		room[] roomQueue;
		room* currentRoom;
		bool[5][5] markedMap;
		
		currentRoom = &globalMap[startPositionY][startPositionX].associatedRoom;
		markedMap[startPositionY][startPositionX] = true;
		
		while(currentRoom !is null)
		{
			totalEnemies += currentRoom.enemiesInRoom.length;
			
			if(currentRoom.y != 0 && globalMap[currentRoom.y-1][currentRoom.x].visited == 0 && !markedMap[currentRoom.y-1][currentRoom.x])
			{
				roomQueue ~= globalMap[currentRoom.y-1][currentRoom.x].associatedRoom;
				markedMap[currentRoom.y-1][currentRoom.x] = true;
			}
			if(currentRoom.x != 0 && globalMap[currentRoom.y][currentRoom.x-1].visited == 0 && !markedMap[currentRoom.y][currentRoom.x-1])
			{
				roomQueue ~= globalMap[currentRoom.y][currentRoom.x-1].associatedRoom;
				markedMap[currentRoom.y][currentRoom.x-1] = true;
			}
			if(currentRoom.x != 4 && globalMap[currentRoom.y][currentRoom.x+1].visited == 0 && !markedMap[currentRoom.y][currentRoom.x+1])
			{
				roomQueue ~= globalMap[currentRoom.y][currentRoom.x+1].associatedRoom;
				markedMap[currentRoom.y][currentRoom.x+1] = true;
			}
			if(currentRoom.y != 4 && globalMap[currentRoom.y+1][currentRoom.x].visited == 0 && !markedMap[currentRoom.y+1][currentRoom.x])
			{
				roomQueue ~= globalMap[currentRoom.y+1][currentRoom.x].associatedRoom;
				markedMap[currentRoom.y+1][currentRoom.x] = true;
			}
				
			if(roomQueue.length == 0)
				currentRoom = null;
			else
				currentRoom = &roomQueue[0];
			roomQueue = roomQueue[1..$];
		}
	}
	
	char[] printLevel()
	{
		char[] returnString = "";
		
		for(int i = 0; i < 5; i++)
		{
			for(int j = 0; j < 5; j++)
			{
				returnString = returnString ~ cast(char)('0' + globalMap[i][j].visited);
			}
			returnString = returnString ~ "\n";
		}
		
		return returnString;
	}
}
