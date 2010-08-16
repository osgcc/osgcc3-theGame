files = theGame.d enemies.d map.d globals.d items.d player.d scoreboard.d
objects = theGame.o enemies.o map.o globals.o items.o player.o scoreboard.o

theGame : $(files)
	ldc -L -lncurses -L -lncursesw -I../ycurses/modules $(files)
	
clean :
	rm -rf $(objects) *~ theGame
