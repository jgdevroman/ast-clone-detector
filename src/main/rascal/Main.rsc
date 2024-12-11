module Main

import IO;
import util::FileSystem;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Utility;
import CloneDetection;

void main() {
    list[str] entries = listEntries(|cwd:///projects|);

    println("Start analyzing following projects: <entries>. Can take a few minutes..");
    
    for(entry <- entries) {
        if(entry == ".gitkeep" || entry == "hsqldb-2.3.1" || entry == "TestClone1") {
            continue;
        }
        projectLocation = |cwd:///projects/| + entry;
        set[loc] fileLocations = find(projectLocation, "java");
        list[Declaration] asts = getASTs(projectLocation);

        basicCloneDetection(asts, threshold=4000);
    }
}