module enemies;

import player;

Enemy function(int, int)[] availableEnemies;

static this()
{
	availableEnemies ~= &Bug.init;
	availableEnemies ~= &Wolf.init;
	availableEnemies ~= &Imp.init;
	availableEnemies ~= &Spider.init;
	availableEnemies ~= &Unknown.init;
	availableEnemies ~= &Parent.init;
	availableEnemies ~= &Zombie.init;
	availableEnemies ~= &Centaur.init;
	availableEnemies ~= &Llama.init;
	availableEnemies ~= &Gravity.init;
	availableEnemies ~= &Ninja.init;
}

abstract class Enemy
{
	int	 score;
	char symbol;
	char[] name;
	int  y_pos, x_pos;
	int  level;
	int  power;
	int  defense;
	double hp;

	static Enemy init(int y, int x);

	void move(int y, int x)
	{
		y_pos = y;
		x_pos = x;
	}

	double attack(Player hero)
	{
		double damage = cast(double)power/hero.defense;
		hero.hp -= damage;
		return damage;
	}
}

class Bug : Enemy
{
	this(int y, int x)
	{
		score	= 1;
		symbol  = 'b';
		name  = "bug";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 1;
		hp		= 1;
		level 	= 1; //bugs suck, they'll always be level 1
	}

	static Enemy init(int y, int x)
	{
		return new Bug(y,x);
	}
}

class Wolf : Enemy
{
	this(int y, int x)
	{
		score	= 2;
		symbol  = 'w';
		name  = "wolf";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 1;
		hp		= 2;
		level 	= 1;
	}

	static Enemy init(int y, int x)
	{
		return new Wolf(y,x);
	}
}

class Imp : Enemy
{
	this(int y, int x)
	{
		score	= 2;
		symbol  = 'i';
		name  = "imp";
		y_pos	= y;
		x_pos	= x;
		power	= 2;
		defense = 1;
		hp		= 1;
		level 	= 1;
	}

	static Enemy init(int y, int x)
	{
		return new Imp(y,x);
	}
}

class Spider : Enemy
{
	this(int y, int x)
	{
		score	= 4;
		symbol  = 's';
		name  = "spider";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 2;
		hp		= 2;
		level 	= 2;
	}

	static Enemy init(int y, int x)
	{
		return new Spider(y,x);
	}
}

class Unknown : Enemy
{
	this(int y, int x)
	{
		score	= 5;
		symbol  = 'q';
		name  = "unknown";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 1;
		hp		= 1;
		level 	= 3;
	}

	static Enemy init(int y, int x)
	{
		return new Unknown(y,x);
	}
}

class Parent : Enemy
{
	this(int y, int x)
	{
		score	= 6;
		symbol  = 'P';
		name  = "parent! You terrible child!";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 2;
		hp		= 6;
		level 	= 3;
	}

	static Enemy init(int y, int x)
	{
		return new Parent(y,x);
	}
}

class Zombie : Enemy
{
	this(int y, int x)
	{
		score	= 4;
		symbol  = 'w';
		name  = "zombie ... or did you?";
		y_pos	= y;
		x_pos	= x;
		power	= 2;
		defense = 1;
		hp		= 2;
		level 	= 2;
	}

	static Enemy init(int y, int x)
	{
		return new Zombie(y,x);
	}
}

class Centaur : Enemy
{
	this(int y, int x)
	{
		score	= 3;
		symbol  = 'c';
		name  = "centaur";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 3;
		hp		= 2;
		level 	= 3;
	}

	static Enemy init(int y, int x)
	{
		return new Centaur(y,x);
	}
}

class Llama : Enemy
{
	this(int y, int x)
	{
		score	= 2;
		symbol  = 'l';
		name  = "llama";
		y_pos	= y;
		x_pos	= x;
		power	= 1;
		defense = 2;
		hp		= 1;
		level 	= 1;
	}

	static Enemy init(int y, int x)
	{
		return new Llama(y,x);
	}
}

class Gravity : Enemy
{
	this(int y, int x)
	{
		score	= 4;
		symbol  = 'g';
		name  = "gravity?";
		y_pos	= y;
		x_pos	= x;
		power	= 3;
		defense = 1;
		hp		= 1;
		level 	= 2;
	}

	static Enemy init(int y, int x)
	{
		return new Gravity(y,x);
	}
}

class Ninja : Enemy
{
	this(int y, int x)
	{
		score	= 20; //change this
		symbol  = ' ';
		name  = "ninja! you must be pretty good";
		y_pos	= y;
		x_pos	= x;
		power	= 4;
		defense = 1;
		hp		= 5;
		level 	= 5; //OH FUCK IT'S A NINJA
	}

	static Enemy init(int y, int x)
	{
		return new Ninja(y,x);
	}
}


