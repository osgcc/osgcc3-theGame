module scoreboard;

import tango.io.Stdout;
import tango.io.Console;
import tango.io.stream.TextFile;
import tango.sys.Environment;
import tango.text.Util;
import tango.core.Array;
import Integer = tango.text.convert.Integer;
import Path = tango.io.Path;
import tango.stdc.string;

char[] scoreBoardFile = "scoreBoard.txt";

static this()
{
	if(!Path.exists(scoreBoardFile))
	{
		auto output = new TextFileOutput(scoreBoardFile, (File).WriteCreate);
			output.format("0 martin 50\n");
		output.format("end");
		output.flush.close();
	}
}

struct ranking
{
	int rank;
	char[] user;
	int score;
};


void update_scoreboard(int score)
{
	int i=0;
	ranking curr_ranking;
 	ranking[] top_scores;

	curr_ranking.rank = 0;
	curr_ranking.user = Environment.get("USER",null);
	curr_ranking.score = score;
	top_scores ~= curr_ranking;

	auto input = new TextFileInput(scoreBoardFile, (File).ReadExisting);
	foreach(line; input)
	{
		if(line == "end") break;
		auto line_values = split(line," ");
		curr_ranking.rank = Integer.parse(line_values[0]);
		curr_ranking.user = line_values[1];
		Stdout(curr_ranking.user);
		curr_ranking.score = Integer.parse(line_values[2]);
		top_scores ~= curr_ranking;
	}
	input.close();

	top_scores.sort( 
		(ranking a, ranking b)
		{ return a.score >= b.score; });	

	auto output = new TextFileOutput(scoreBoardFile, (File).WriteCreate);
	for(i=0; i<top_scores.length; i++)
	{
		top_scores[i].rank = i+1;
		output.format("{} {} {}\n",top_scores[i].rank,
					   top_scores[i].user,top_scores[i].score);
	}
	output.format("end");
	output.flush.close();
	
}

char[] print_scores()
{
	int i=0;
	ranking curr_ranking;
 	ranking[] top_scores;
 	char[] returnString;
 	int count = 0;

	returnString ~= "\t ------ HIGH SCORES ------\n\n";
	
	auto input = new TextFileInput(scoreBoardFile, (File).ReadExisting);
	foreach(line; input)
	{
		if(count == 10)
			break;
		if(line == "end") break;
		returnString ~= "\t\t" ~ line ~ "\n";
		count++;
	}
	input.close();

	return returnString;

}
