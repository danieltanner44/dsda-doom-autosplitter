# dsda-doom autosplitter

A [dsda-doom](https://github.com/kraflab/dsda-doom) autosplitter for [LiveSplit](http://livesplit.org/).

Note: the current implementation of this autosplitter will autodetect the version of dsda-doom used and is compatible with the following dsda-doom versions:
+ 0.30.1
+ 0.30.0
+ 0.29.4
+ 0.29.3
+ 0.29.0
+ 0.28.3

## Usage
1. Download [dsda-doom.asl](https://raw.githubusercontent.com/Krankdud/dsda-doom-autosplitter/main/dsda-doom.asl)
2. Add the *Scriptable Auto Splitter* component to your layout
3. Set the script path for the auto splitter component to where dsda-doom.asl is located
4. Set LiveSplit to compare against game time

I recommend not showing milliseconds on your timer or splits. The auto splitter truncates the milliseconds
so it matches movie runs.

## Updating the autosplitter
For the autosplitter to be compatible with a specific release of dsda-doom the autosplitter script must contain the configuration information associated with that release. This section provides information about how to update the autosplitter to work with additional versions of dsda-doom. This is achieved by updating two key sections of the dsda-doom.asl file, namely:
1. State Block Definition - Adding the associated state block for the new dsda-doom verion (providing the memory addresses for that version)
2. Version Detection - Adding the dsda-doom memory size and updating the associated logic to enable auto-detection of the added dsda-doom version

Note: If you are uncertain about the update process it can be helpful to apply it to a currently compatible release and check that the correct memory addresses and memory sizes are identified.

### Adding a State Block Definition
Each version of dsda-doom will require an associated state block to be defined at the top of the dsda-doom.asl file. To update this follow these two steps:
1. Find the required memory addresses
2. Add these to a new state block at the top of the dsda-doom.asl file

The autosplitter state block defines six memory addresses: game tic, game state (intermission), current map, current attempt, menu state, and demo playback state.   

I use [Cheat Engine](https://cheatengine.org/) to find these addresses.

Here's the general strategy I use to get the memory addresses. For some of these, there seem to be
multiple addresses that work.

Game tic:
1. Pause the game and convert the current time to tics. Doom runs at 35 tics per second.
2. Search for the tics as a four byte value.
3. Let the game run a bit, repeat steps 1 and 2.
4. Repeat until you're confident that you have the tics address.
Note: there are two similar game timers and one resets once inputs have been used (move Doomguy or fire a weapon) - use the memory address of the timer that does not reset.

Game state:
1. Start in a map and search for a 0 as a four byte value.
2. Exit the map and while in the intermission, search for a 1.
3. Go to the next map, search for a 0.
4. Repeat until you find the game state address.
Note: some memory addresses do not change to 1 when on the episode completion intermission screen - choose one that does change to 1

Map:
1. Start in map01 and search for a 1 as a four byte value.
2. Go to some other map, search for that map number
3. Repeat until you find the map address.
Note: use IDCLEV cheat or "Previous Level" / "Next Level" keybinds to jump to different maps when searching for valid memory addresses 

Attempt:
1. Start a demo and search for a 1 as a four byte value.
2. Hit the restart demo attempt button, and search for a 2.
3. Repeat until you find the attempt address.
Note: the attempt number to find is the one for that session, e.g., in the Demos menu set "Show Demo Attempts" to "True". The memory address to find is for the number X shown in game as “Attempt X / Y”. Restart the session and confirm the memory addresses resets to the expected value

Menu state:
1. Start in a map, press Esc, and search for a 1 as a four byte value.
2. Press Esc again, and search for a 0 as a four byte value.
3. Repeat until you find the menu state address.

Demo playback state:
1. Launch into main menu, wait for demo lump playback, and search for a 1 as a four byte value.
2. Start a demo recording and search for a 0 as a four byte value.
3. Repeat until you find the demo playback address.
Note: when the demo lump is playing back choose a memory address that goes to 0 on the text screens between demos

The memory addresses go into the state block at the top of dsda-doom.asl.
If the addresses in Cheat Engine show up as "dsda-doom"+#######, use the value after the plus in the script.

### Adding Version Detection
The autosplitter script needs to identify the version of dsda-doom that is in use, so the correct state block (memory locations) are used. The script allows automatic identifion of the version of dsda-doom by determining the memory size of the dsda-doom process. To add compatibility for an additional version of dsda-doom the memory size of its process must be determined. To update this follow these two steps:
1. Find the required dsda-doom memory size
2. Add this to the version detection logic in the dsda-doom.asl file, e.g., 
    else if (memory_size == "XXXXXX")
        version = "X.YY.Z";

Find dsda-doom memory size:
1. Use a debug viewer to display output from the LiveSplit process (e.g., [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview))
2. Whilst the debug viewer is active, open LiveSplit. Note the layout used must contain the latest dsda-doom.asl *Scriptable Auto Splitter* component
3. Launch the new version of dsda-doom
4. In the debug viewer look for the line "dsda-doom memory size is: XXXXXX", here the XXXXXX is the string that encodes the required memory size

Each version of dsda-doom requires the associated version logic to be present in the dsda-doom.asl file.