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
        // if(entry == ".gitkeep" || entry == ".DS_Store" || entry == "smallsql0.21_src" || entry == "hsqldb-2.3.1") {
        if(entry == ".gitkeep" || entry == ".DS_Store") {
            continue;
        }
        println("Analyzing project: <entry>");
        projectLocation = |cwd:///projects/| + entry;
        set[loc] fileLocations = find(projectLocation, "java");
        list[Declaration] asts = getASTs(projectLocation);

        type1CloneClasses = basicCloneDetection(asts, threshold=150, type2=false);
        cloneClassesToJson(type1CloneClasses, |cwd:///results/| + entry, entry, "type1");

        type2CloneClasses = basicCloneDetection(asts, threshold=150);
        cloneClassesToJson(type2CloneClasses, |cwd:///results/| + entry, entry, "type2");
    }
}