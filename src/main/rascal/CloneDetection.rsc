module CloneDetection

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Node;
import List;
import String;
import Location;


import Utility;

// Detect type I and type II clones in a given project with the basic clone detection algorithm from Baxter et al.[1]

int MASS_THRESHOLD = 2000;

// Compute the mass of a given AST
int getMass(node subtree) {
    return size(toString(subtree));
}

void basicCloneDetection(list[Declaration] asts, int threshold = MASS_THRESHOLD) {
    map[str, list[node]] hashBucket = ();    
    for(ast <- asts) {
        top-down visit(ast) {
            case node subtree: {
                int mass = getMass(subtree);
                // println(mass);
                if(mass > threshold) {
                    str subtreeHash = hash(unsetRec(subtree));
                    if(subtreeHash in hashBucket) {
                        hashBucket[subtreeHash] = hashBucket[subtreeHash] + [subtree];
                    } else {
                        hashBucket[subtreeHash] = [subtree];
                    }
                }
            }
        }
    }
    
    list[tuple[node,node]] clones = [];
    for(hash <- hashBucket) {
        if(size(hashBucket[hash]) < 2) {
            continue;
        }
        // println("Found clone with hash: <hash> and size: <size(hashBucket[hash])>");
        for(subtree <- hashBucket[hash]) {
            for(node clone <- clones) {
                for (node subTreeChildren <- getChildren(subtree)) {
                    if(subTreeChildren == clone) {
                        println("subtree <clone.src> in <subtree.src>");
                        delete(clones, indexOf(clones, clone));
                    }
                }
            }
            clones += [subtree];
        }
    }
    println(size(clones));
    for(node clone <- clones) {
        // println("Found clone with hash: <hash(unsetRec(clone))> and size: <getMass(clone)>");
        println(clone.src);
    }
}

void main() {
    Declaration ast = createAstFromFile(|cwd:///projects/TestClone1/Clone1.java|, true);
    list[Declaration] asts = [ast];
    basicCloneDetection(asts);
}

// [1] I. D. Baxter, A. Yahin, L. Moura, M. Sant'Anna and L. Bier, "Clone detection using abstract syntax trees," Proceedings. International Conference on Software Maintenance (Cat. No. 98CB36272), Bethesda, MD, USA, 1998, pp. 368-377, doi: 10.1109/ICSM.1998.738528, https://ieeexplore.ieee.org/abstract/document/738528