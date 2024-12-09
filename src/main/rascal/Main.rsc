module Main

import IO;
import util::FileSystem;

void main() {
    list[str] entries = listEntries(|cwd:///projects|);

    println("Start analyzing following projects: <entries>. Can take a few minutes..");
    
    for(entry <- entries) {
        if(entry == ".gitkeep") {
            continue;
        }
        projectLocation = |cwd:///projects/| + entry;
        set[loc] fileLocations = find(projectLocation, "java");
        print(projectLocation);
    }
}