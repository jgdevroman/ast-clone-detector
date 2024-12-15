
module Volume

import lang::java::m3::Core;
import lang::java::m3::AST;

import IO;
import List;
import Set;
import String;
import Map;
import Node;

import Utility;


int getVolume(set[loc] locations) {
    totalCount = 0;
    for (l <- locations){
        code = readFile(l);
        totalCount += getLineCount(code);
    }

    return totalCount;
}

int getLineCount(str code) {
    for (/<comment:\/\*[\s\S]*?\*\/>/ := code) { 
        code = replaceAll(code, comment, "");
    }
    
    list[str] lines = split("\n", code);
    int totalCount = 0;

    for (str line <- lines) {
      line = trim(line);

      if(!isRedundantLine(line)) {
        totalCount += 1; 
      }
    }

    return totalCount;
}
