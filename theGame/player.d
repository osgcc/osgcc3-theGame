module player;

import tango.io.Stdout;
import enemies;
import items;
import globals;

class Player
{
	int score;
	char symbol;
	int y_pos, x_pos;
	int power;
	int weapon;
	int defense;
	int armor;
	double hp;
	double maxhp;
	direction dir;
	Item[] inventory;


	this(int y, int x)
	{
		symbol  = 'v';
		score	= 0;
		y_pos	= y;
		x_pos	= x;
		dir		= SOUTH;
		power	= 0;
		defense = 1;
		hp		= 5;
		maxhp	= 5;
		weapon  = 0;
		armor   = 0;
		inventory.length = 0;
		this.pick_up(new Tunic(y,x));
		inventory[0].use(this);
		this.pick_up(new Basic_sword(y,x));
		inventory[1].use(this);
		this.pick_up(new Health_potion(y,x));
		this.pick_up(new Health_potion(y,x));
	}

	static Player init(int y, int x)
	{
		return new Player(y,x);
	}

	void move(int y, int x)
	{
		y_pos = y;
		x_pos = x;
	}

	/* attacks target enemy and reduces their hp,
	   return damage done */
	double attack(Enemy monster)
	{
		double damage = cast(double)power/monster.defense;
		monster.hp -= damage;
		if(monster.hp <= 0)
		{
			score += monster.score;
		}

		return damage;
	}

	/* picks up an item and adds it into the player inventory,
	   returns Item */
	bool pick_up(Item item)
	{
		Consumable temp;

		if(inventory.length < 26)
		{
			/* if the item is a consumable, check to see if we
			   already have it and just add a charge if we do */
			if((temp = cast(Consumable)item) !is null)
			{
				int i;
				for(i=0; i<inventory.length; i++)
				{
					if(temp.name == inventory[i].name)
					{
						temp = cast(Consumable)inventory[i];
						temp.charges++;
						break;
					}
				}
				if(i == inventory.length)
				{
					inventory ~= item;
				}
			}
			else
			{
				inventory ~= item;
			}
			return true;
		}
		else
		{
			return false;
		}
	}

	/* removes an item from the inventory,
	   returns removed item */
	Item discard(int item_num)
	{
		if(item_num < inventory.length)
		{
			Item item = inventory[item_num];
			Armor  temp_a;
			Weapon temp_w;
			bool discardable = true;
			
			if(cast(Armor)item !is null)
			{
				temp_a = cast(Armor)item;
				if(temp_a.equipped) discardable = 0;
			}
			else if(cast(Weapon)item !is null)
			{
				temp_w = cast(Weapon)item;
				if(temp_w.equipped) discardable = 0;
			}
		
			if(discardable)
			{
				item.y_pos = this.y_pos;
				item.x_pos = this.x_pos;

				inventory = inventory[0 .. item_num]~inventory[item_num+1 .. $];
				return item;			
			}
			else
			{
				return null;
			}
			
		}
		
		return null;
	}

	/* uses an item 
		  consumables: will reduce the charges and remove it from the inventory
					   if no charges remain
		  armor/weapon: equips if not equipped, else unequipps 

	   returns false if item was not used, returns true if used */
	bool use_item(int item_num)
	{
		if(item_num > inventory.length) return false;
		else
		{
			Consumable temp;
			if(!inventory[item_num].use(this))
			{
				return false;
			}
			if(cast(Consumable)inventory[item_num] !is null)
			{
				temp = cast(Consumable)inventory[item_num];
				temp.charges -= 1;
				if(temp.charges <= 0)
					discard(item_num);
			}
			return true;
		}
	}

	void throw_at(Item something)
	{
		/* throw an item at someone? */
	}
	
	void change_direction(direction dir)
	{
		this.dir = dir;
		
		switch(dir)
		{
			case NORTH:
				symbol = '^';
				break;
			case EAST:
				symbol = '>';
				break;
			case WEST:
				symbol = '<';
				break;
			case SOUTH:
				symbol = 'v';
				break;
		}
	}
	
	char[] print_inventory()
	{
		int i;
		char[] returnString;

		for(i=0; i<inventory.length; i++)
		{
			if(cast(Consumable)inventory[i] is null)
			{
				returnString ~= cast(char)('a'+i) ~ ": " ~ inventory[i].name;
				if(cast(Weapon)inventory[i] !is null)
				{
					Weapon foo = cast(Weapon)inventory[i];
					if(foo.equipped)
						returnString ~= "(equipped)";
				}
				else if(cast(Armor)inventory[i] !is null)
				{
					Armor foo = cast(Armor)inventory[i];
					if(foo.equipped)
						returnString ~= "(equipped)";
				}
			}
			else
			{
				Consumable foo = cast(Consumable)inventory[i];
				returnString ~= cast(char)('a'+i) ~ ": " ~ foo.name ~ "(" ~ cast(char)('0'+foo.charges) ~ ")";
			}
			returnString ~= "\n";
		}
		
		return returnString;
	}
	
	char[] print_inventory_symbols()
	{
		int i;
		char[] returnString;
		
		for(i=0; i<inventory.length; i++)
		{
			returnString ~= cast(char)('a'+i);
		}
		
		return returnString;
	}

}

