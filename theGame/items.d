module items;

import tango.io.Stdout;
import player;

Item function(int y, int x)[] availableItems;

static this()
{
	availableItems ~= &Health_potion.init;
	availableItems ~= &Tunic.init;
	availableItems ~= &Leather_armor.init;
	availableItems ~= &Chain_mail.init;
	availableItems ~= &Scale_mail.init;
	availableItems ~= &Plate_mail.init;
	availableItems ~= &Adamantite_armor.init;
	availableItems ~= &Wagar.init;
	availableItems ~= &Basic_sword.init;
	availableItems ~= &Long_sword.init;
	availableItems ~= &Broad_sword.init;
	availableItems ~= &Katana.init;
	availableItems ~= &Claymore.init;
	availableItems ~= &Hrunting.init;
	availableItems ~= &Giants_sword.init;
	availableItems ~= &Spam.init;
}

abstract class Item
{
	char symbol;
	char[] name;
	int y_pos, x_pos;
	
	/* define init for positions */
	this(int y, int x, char[] str, char sym)
	{
		y_pos = y;
		x_pos = x;
		name = str;
		symbol = sym;
	}

	static Item init(int y, int x);

	bool use(Player)
	{
		return false;
	}
}


/*************************************
 *
 *	          Consumables 
 *
 *************************************/
abstract class Consumable : Item
{
	int charges;

	this(int y, int x, char[] name, char sym, int charges)
	{
		super(y, x, name, sym);
		this.charges = charges;
	}

	override bool use(Player p) 
	{
		return false;
	}
}


class Health_potion : Consumable
{
	int power;
	int charges;


	this(int y, int x)
	{
		super(y,x,"Health Potion",'!',1);
		power = 3;
	}

	static Item init(int y, int x)
	{
		return new Health_potion(y,x);
	}

	override bool use(Player hero)
	{
		hero.hp += power;
		if(hero.hp > hero.maxhp) hero.hp = hero.maxhp;
		return true;
	}
}


class Spam : Consumable
{
	int power;
	int charges;


	this(int y, int x)
	{
		super(y,x,"Spam!",'?',1);
		power = 1;
	}

	static Item init(int y, int x)
	{
		return new Spam(y,x);
	}

	override bool use(Player hero)
	{
		hero.maxhp += power;
		hero.hp += power;
		return true;
	}
}


/*************************************
 *
 *	             Armor    
 *
 *************************************/
abstract class Armor : Item
{
	int  defense;
	bool equipped;

	this(int y, int x, char[] name, char sym, int def)
	{
		super(y, x, name, sym);
		defense	 = def;
		equipped = false;
	}

	override bool use(Player hero)
	{
		if(!equipped && hero.armor == 0)
		{
			equipped = true;
			hero.armor = 1;
			hero.defense += defense;
		}
		else if(equipped)
		{
			equipped = false;
			hero.armor = 0;
			hero.defense -= defense;
		}
		else
		{
			return false;
		}
		return true;
	}
}


class Tunic : Armor
{
	this(int y, int x)
	{
		super(y,x,"Tunic",'H',0);
	}

	static Item init(int y, int x)
	{
		return new Tunic(y,x);
	}

	override bool use(Player P)
	{
		return false;
	}
}

class Leather_armor : Armor
{
	this(int y, int x)
	{
		super(y,x,"Leather Armor",'H',1);
	}

	static Item init(int y, int x)
	{
		return new Leather_armor(y,x);
	}
}

class Chain_mail : Armor
{
	this(int y, int x)
	{
		super(y,x,"Chain Mail",'H',2);
	}

	static Item init(int y, int x)
	{
		return new Chain_mail(y,x);
	}
}

class Scale_mail : Armor
{
	this(int y, int x)
	{
		super(y,x,"Scale Mail",'H',3);
	}

	static Item init(int y, int x)
	{
		return new Scale_mail(y,x);
	}
}

class Plate_mail : Armor
{
	this(int y, int x)
	{
		super(y,x,"Plate Mail",'H',4);
	}

	static Item init(int y, int x)
	{
		return new Plate_mail(y,x);
	}

}

class Adamantite_armor : Armor
{
	this(int y, int x)
	{
		super(y,x,"Adamantite Armor",'H',6);
	}

	static Item init(int y, int x)
	{
		return new Adamantite_armor(y,x);
	}

}

class Wagar : Armor
{
	this(int y, int x)
	{
		super(y,x,"Wagar",'H',7);
	}

	static Item init(int y, int x)
	{
		return new Wagar(y,x);
	}

}

/*************************************
 *
 *	            Weapon   
 *
 *************************************/
abstract class Weapon : Item
{
	int  power;
	bool equipped;

	this(int y, int x, char[] name, char sym, int pow)
	{
		super(y, x, name, sym);
		power   	= pow;
		equipped	= false;
	}

	override bool use(Player hero)
	{
		if(!equipped && hero.weapon == 0)
		{
			equipped = true;
			hero.weapon = 1;
			hero.power += power;
		}
		else if(equipped)
		{
			equipped = false;
			hero.weapon = 0;
			hero.power -= power;
		}
		else
		{
			return false;
		}
		return true;
	}
}


class Basic_sword : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Basic Sword",'/',1);
	}

	static Item init(int y, int x)
	{
		return new Basic_sword(y,x);
	}
}

class Long_sword : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Long Sword",'/',2);
	}

	static Item init(int y, int x)
	{
		return new Long_sword(y,x);
	}
}

class Broad_sword : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Broad Sword",'/',3);
	}

	static Item init(int y, int x)
	{
		return new Broad_sword(y,x);
	}
}

class Katana : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Katana",'/',4);
	}

	static Item init(int y, int x)
	{
		return new Katana(y,x);
	}
}

class Claymore : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Claymore",'/',5);
	}

	static Item init(int y, int x)
	{
		return new Claymore(y,x);
	}
}

class Hrunting : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Hrunting",'/',6);
	}

	static Item init(int y, int x)
	{
		return new Hrunting(y,x);
	}
}

class Giants_sword : Weapon
{
	this(int y, int x)
	{
		super(y,x,"Giant's Sword",'/',7);
	}

	static Item init(int y, int x)
	{
		return new Giants_sword(y,x);
	}
}

