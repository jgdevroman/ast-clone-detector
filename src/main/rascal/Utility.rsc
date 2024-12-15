module Utility

import IO;
import Node;
import String;
import List;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::json::IO;

alias JsonRec = map[str, value];

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

// Compute the hash of a given subtree
str hash(value s) { 
    return md5Hash(s); 
}

void cloneClassesToJson(map[str, list[tuple[node, loc]]] cloneClasses, loc outputLocation, str entry) {
    JsonRec treemapJson = cloneClassesToTreemapJson(cloneClasses, entry);
    writeJSON(outputLocation + "Treemap.json", treemapJson);

    JsonRec cloneClassJson = cloneClassesToJsonRec(cloneClasses);
    writeJSON(outputLocation + "Classes.json", cloneClassJson);
}

JsonRec cloneClassesToJsonRec(map[str, list[tuple[node, loc]]] cloneClasses) {
    JsonRec json = ();
    for (cloneClassHash <- cloneClasses) {
        list[tuple[node, loc]] cloneClass = cloneClasses[cloneClassHash];
        classRecords = ();
        for (clone <- cloneClass) {
            loc l = clone[1];
            JsonRec src = ("src": l);
            JsonRec path = ("path": l.path);
            JsonRec file = ("file": l.file);
            JsonRec length = ("length": l.length);
            JsonRec beginLine = ("beginLine": l.begin.line);
            JsonRec beginColumn = ("beginColumn": l.begin.column);
            JsonRec endLine = ("endLine": l.end.line);
            JsonRec endColumn = ("endColumn": l.end.column);
            classRecords[hash(clone)] = src + path + file + length + beginLine + beginColumn + endLine + endColumn;
        }
        json[cloneClassHash] = classRecords;
    }
    return json;
}

JsonRec cloneClassesToTreemapJson(map[str, list[tuple[node, loc]]] cloneClasses, str entry) {
    fileRecords = ("name": entry, "children": []);
    list[JsonRec] treemapJsons = [];
    for (cloneClassHash <- cloneClasses) {
        list[tuple[node, loc]] cloneClass = cloneClasses[cloneClassHash];
        for (clone <- cloneClass) {
            loc l = clone[1];
            str path = l.path;
            // int length = l.length;
            list[str] files = split("/", path);
            // filter empty strings and "projects" from the path
            files = [f | f <- files, f != "" && f != "projects" && f != entry];
            treemapJsons = addPathToTreemapJson(files, treemapJsons, l, cloneClassHash);
            fileRecords["children"] = treemapJsons;
        }
    }
    return fileRecords;
}

list[JsonRec] addPathToTreemapJson(list[str] path, list[JsonRec] srcJson, loc src, str cloneClassHash) {
    if(size(path) == 0) {
        return srcJson += ("src": src, "cloneClassHash": cloneClassHash, "value": src.length, "name": src.file);
    }
    newJson = srcJson;
    // println("newJson: <newJson>");
    for (i <- [0..size(newJson)]) {
        json = newJson[i];
        if(json["name"] == path[0]) {
            newJson[i]["children"] = addPathToTreemapJson(path[1..], json["children"], src, cloneClassHash);
        }
    }
    if(newJson == srcJson) {
        // println("Add new path: <path[0]>");
        newJson += ("name": path[0], "children": addPathToTreemapJson(path[1..], [], src, cloneClassHash));
    }

    return newJson;
}