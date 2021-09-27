/*
oldSRC.asl - An ASL script for the auto-splitter and load remover for the game SRC
v0.0.1
Made by VelmaDilemma
*/
state("SRC")
{
    //Check pointer map OfflineTest2
    float inGameTimer : "UnityPlayer.dll", 0x01483250, 0x368, 0x28, 0x40, 0xA0, 0x50, 0x80, 0x22C;
}
startup
{

    //Could be increased if the community wants to make 3 decimals standard
    refreshRate = 100;
}
init
{
    vars.debouncedebounceCountersMin = 50; //Minimum value to reach for the timer to split (multiply by refresh rate to get the total debounce time)
    vars.debounceCounter = 0; //Used as a debounce of sorts in case the variable does not update
    vars.levelAdded = false; //Determines if a level's splits have been added to the sum of splits
    vars.splitYet = false; //Whether or not the timer has split
    vars.sumOfILs = 0; //Sum of times from each Individual Level
    vars.oldSumOfILs = 0; //The value of Sum of Times without the current IL split
}
start
{
    if(old.inGameTimer==0 && current.inGameTimer!=old.inGameTimer)
    {
        return true;
    }
    //Resets all values
    vars.debounceCounter = 0;
    vars.levelAdded = false; 
    vars.splitYet = false; 
    vars.sumOfILs = 0;
    vars.oldSumOfILs = 0;
}
isLoading
{
    return true; //Forces the timer to always use in game time
}
gameTime
{
    if (current.inGameTimer==old.inGameTimer) //Checks if the game/livesplit has simply frozen for a small time (perhaps if fps<100) and starts a debounce timer
    {
        vars.debounceCounter+=1; 
    }
    else
    {
        vars.debounceCounter=0;
    }
    if (vars.debounceCounter>vars.debounceCountersMin && vars.levelAdded==false) //If the track is confirmed to be over, the timer is added to the sum of Level Times
    {
        vars.sumOfILs+=current.inGameTimer;
        vars.levelAdded=true;
    }
    if (old.inGameTimer==0) //Debounce is reset; timer is primed to add the next level; sets the Sum of Level Times to be current as the new in game timer is 0 and not the old level's
    {
        vars.levelAdded=false;
        vars.debounceCounter=0;
        vars.oldSumOfILs=vars.sumOfILs;
    }
    vars.realInGameTime = vars.oldSumOfILs + (double)current.inGameTimer;
    TimeSpan span = TimeSpan.FromSeconds((double)(new decimal(vars.realInGameTime)));
    return span;
}
split
{
    //Occurs after the isLoading hence splits are done at the start of a new track
    //Checks that the previous track was finished
    print("Timer: " + current.inGameTimer);
    if (vars.debounceCounter>vars.debounceCountersMin && vars.splitYet==false && current.inGameTimer!=0)
    {
        vars.splitYet=true;
        return true;
    }
    if (current.inGameTimer==0)
    {
        vars.splitYet=false;
    }
}
