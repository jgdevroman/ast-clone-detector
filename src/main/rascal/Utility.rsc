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

void cloneClassesToJson(map[str, list[tuple[node, loc]]] cloneClasses, loc outputLocation) {
    JsonRec json = cloneClassesToTreemapJson(cloneClasses);
    writeJSON(outputLocation, json);
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

JsonRec cloneClassesToTreemapJson(map[str, list[tuple[node, loc]]] cloneClasses) {
    fileRecords = ("name": "root", "children": []);
    for (cloneClassHash <- cloneClasses) {
        list[tuple[node, loc]] cloneClass = cloneClasses[cloneClassHash];
        for (clone <- cloneClass) {
            loc l = clone[1];
            str path = l.path;
            int length = l.length;
            list[str] files = split("/", path);
            // filter empty strings and "projects" from the path
            files = [f | f <- files, f != "" && f != "projects"];
            files = ["root"] + files;
            println(files);
            fileRecords = addPathToTreemapJson(files, fileRecords, fileRecords["children"], l, cloneClassHash);
        }
    }
    return fileRecords;
}

JsonRec addPathToTreemapJson(list[str] path, JsonRec srcJson, list[JsonRec] children, loc src, str cloneClassHash) {
    JsonRec json = srcJson;
    if(size(path) == 0) {
        return ("src": src, "cloneClassHash": cloneClassHash);
    }
    if(size(path) == 1) {
        if (json["name"] == "") {
            json["name"] = path[0];
            newChild = addPathToTreemapJson([], ("name": "","children": []), [], src, cloneClassHash);
            json["children"] = [newChild];
        }
        else if(json["name"] == path[0]) {
            children = json["children"];
            newChild = addPathToTreemapJson([], ("name": "","children": []), [], src, cloneClassHash);
            children += [newChild];
            json["children"] = children;
        }
        
        return json;
    }

    if(json["name"] == "") {
        json["name"] = path[0];
        newChild = addPathToTreemapJson(path[1..], ("name": "","children": []), [], src, cloneClassHash);
        json["children"] = [newChild];
        return json;
    }

    if(json["name"] == path[0]) {
        if(size(children) == 0) {
            newChild = addPathToTreemapJson(path[1..], ("name": "","children": []), [], src, cloneClassHash);
            json["children"] = [newChild];
            return json;
        }
        if(size(children) > 0){
            for (i <- [0..size(children)]) {
                child = children[i];
                grandChildren = child["children"];
                newChild = addPathToTreemapJson(path[1..], child, grandChildren, src, cloneClassHash);
                children = delete(children, i);
                children += [newChild];
                json["children"] = children;
            }
        }
    }
    
    if(srcJson == json) {
        println("No changes");
        newChild = addPathToTreemapJson(path[1..], ("name": "","children": []), [], src, cloneClassHash);
        children = json["children"];
        children += [newChild];
        json["children"] = children;
    }

    return json;
}