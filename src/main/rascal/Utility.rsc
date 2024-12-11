module Utility

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;


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
