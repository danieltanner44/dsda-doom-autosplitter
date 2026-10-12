// Define states to provide memory addresses for different versions of dsda-doom
// To allow compatibility for a new version of dsda-doom an associated state block must be added 
state("dsda-doom", "0.30.1") {
    int gametic: 0x9AE3B0;
    int gamestate: 0x863BB4;
    int map: 0x760EE4;
    int attempt: 0x740728;
    int isMenuOpen: 0x876970;
    int isDemoPlaying: 0x9D24A4;
}

state("dsda-doom", "0.30.0") {
    int gametic: 0x99A810;
    int gamestate: 0x850374;
    int map: 0x750DF4;
    int attempt: 0x730728;
    int isMenuOpen: 0x862E10;
    int isDemoPlaying: 0x9BE904;
}

state("dsda-doom", "0.29.4") {
    int gametic: 0xAEDB90;
    int gamestate: 0x9A2C2C;
    int map: 0x8A1244;
    int attempt: 0x881728;
    int isMenuOpen: 0xB0F74C;
    int isDemoPlaying: 0xB11C78;
}

state("dsda-doom", "0.29.3") {
    int gametic: 0xB11090;
    int gamestate: 0x88BE90;
    int map: 0xB34F40;
    int attempt: 0x970B88;
    int isMenuOpen: 0xB32C4C;
    int isDemoPlaying: 0xB35164;
}

state("dsda-doom", "0.29.0") {
    int gametic: 0x97EF70;
    int gamestate: 0x732590;
    int map: 0x72F7B4;
    int attempt: 0x8182EC;
    int isMenuOpen: 0x9A0B4C;
    int isDemoPlaying: 0x9A3064;
}

state("dsda-doom", "0.28.3") {
    int gametic: 0x96ca90;
    int gamestate: 0x71fef0;
    int map: 0x71d114;
    int attempt: 0x810ad0;
    int isMenuOpen: 0x98E7DC;
    int isDemoPlaying: 0x990BE8;
}

init
{ 
	// Autodetect dsda-doom version based on memory size of its main process
	// This is used to determine the state (memory addresses) to use
    // To allow compatibility for a new version of dsda-doom an associated else if block must be added
    // If a compatible version is not detected the default state will be used (that at the head of this file)
	string memory_size = Convert.ToString(modules.First().ModuleMemorySize, 16);
	print("dsda-doom memory size is: " + memory_size);
	if (memory_size == "a1e000")
        version = "0.28.3";
	else if (memory_size == "a30000")
        version = "0.29.0";
	else if (memory_size == "bcd000")
        version = "0.29.3";
	else if (memory_size == "bc0000")
        version = "0.29.4";
	else if (memory_size == "a6c000")
        version = "0.30.0";
	else if (memory_size == "a7f000")
        version = "0.30.1";
	print("dsda-doom version: " + version + " detected.");
}

startup {
    vars.totalGameTime = 0;

    settings.Add("rta_mode", false, "Set splitter for non-demo runs using RTA without load times.");
}

start {
    // Start only when all pause/menu indicators are gone.
    if (current.isMenuOpen == 0 && current.isDemoPlaying == 0 && current.gamestate == 0) {
        vars.totalGameTime = 0f;
        // In RTA mode, we need to add one tic every level start because DOOM
        // doesn't start from tic 0.
        if (settings["rta_mode"]) {
            vars.totalGameTime += 1;
        }
        
        return true;
    }
}

split {
    // Split on level intermission.
    if (current.gamestate == 1 && old.gamestate == 0) {
        // In RTA mode, we need to add one tic every level start because DOOM
        // doesn't start from tic 0.
        if (settings["rta_mode"]) {
            vars.totalGameTime += 1;
        }
        // In demo mode, this is where we add the current level time to the running total.
        else {
            // Use integer division to truncate the ms to match traditional DOOM timing.
            vars.totalGameTime += current.gametic / 35;
        }

        return true;
    }
}

reset {
    if (!settings["rta_mode"] && current.attempt > old.attempt) {
        return true;
    }

    return false;
}

gameTime {
    // In RTA mode, we keep a running total using delta time because we can no longer
    // rely solely on the level time (for example, to account for saving/loading). 
    if (settings["rta_mode"]) {
        int delta = current.gametic - old.gametic;
        if (delta < 0) {
            delta = 0;
        }

        vars.totalGameTime += delta;

        return TimeSpan.FromSeconds(vars.totalGameTime / 35f);
    }
    // In demo mode, we display the running total + current level time.
    // Milliseconds are truncated to follow traditional DOOM timing.
    else {
        // Just return current total during intermissions.
        // NOTE: Waits one refresh to let the split block run first. 
        if (current.gamestate != 0 && old.gamestate != 0) {
            return TimeSpan.FromSeconds(vars.totalGameTime);
        }

        return TimeSpan.FromSeconds(vars.totalGameTime + current.gametic / 35);
    }
}

isLoading {
    return true;
}

onReset {
    vars.totalGameTime = 0f;
}
