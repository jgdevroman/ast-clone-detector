module Main

import CloneDetection;
import IO;
import Utility;
import lang::java::m3::AST;
import lang::java::m3::Core;
import util::FileSystem;

void main() {
    list[str] entries = listEntries(|cwd:///projects|);

    println("Start analyzing following projects: <entries>. Can take a few minutes..");
    
    for(entry <- entries) {
        if(entry == ".gitkeep" || entry == "hsqldb-2.3.1") {
            continue;
        }
        projectLocation = |cwd:///projects/| + entry;
        set[loc] fileLocations = find(projectLocation, "java");
        list[Declaration] asts = getASTs(projectLocation);

        cloneClasses = basicCloneDetection(asts, threshold=100);
        cloneClassesToJson(cloneClasses, |cwd:///results/| + entry, entry);
    }
}