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

int MASS_THRESHOLD = 4000;

// Compute the mass of a given AST
int getMass(node subtree) {
    return size(toString(subtree));
}

void basicCloneDetection(list[Declaration] asts, int threshold = MASS_THRESHOLD) {
    map[str, list[tuple[node, loc]]] hashBucket = ();    
    for(ast <- asts) {
        top-down visit(ast) {
            case node subtree: {
                int mass = getMass(subtree);
                // println(mass);
                if(mass > threshold) {
                    str subtreeHash = hash(unsetRec(subtree));
                    if(subtreeHash in hashBucket) {
                        hashBucket[subtreeHash] = hashBucket[subtreeHash] + [<subtree, subtree.src>];
                    } else {
                        hashBucket[subtreeHash] = [<subtree, subtree.src>];
                    }
                }
            }
        }
    }

    list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs = createClonePairs(hashBucket);

    println(size(clonePairs));
    for (clonePair <- clonePairs) {
        println("Clone pair: <clonePair[0][1]> and <clonePair[1][1]> with mass <getMass(clonePair[0][0])>");
    }
}

bool isSubClone(tuple[tuple[node, loc], tuple[node, loc]] subClonePair, list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs) {
    for (clonePair <- clonePairs) {
        if(isStrictlyContainedIn(subClonePair[0][1], clonePair[0][1]) && isStrictlyContainedIn(subClonePair[1][1], clonePair[1][1])) {
            println("subtree <subClonePair[0][1]> and <subClonePair[1][1]> is a subclone of <clonePair[0][1]> and <clonePair[1][1]>");
            return true;
        }
    }
    return false;
}
list[tuple[tuple[node, loc], tuple[node, loc]]] deleteSubClonePairs(list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs) {
    list[tuple[tuple[node, loc], tuple[node, loc]]] newClonePairs = clonePairs;
    for (clonePair <- clonePairs) {
        if(isSubClone(clonePair, clonePairs)) {
            newClonePairs = delete(clonePairs, indexOf(clonePairs, clonePair));
            return deleteSubClonePairs(newClonePairs);
        }
    }
    return newClonePairs;
} 

list[tuple[tuple[node, loc], tuple[node, loc]]] createClonePairs(map[str, list[tuple[node, loc]]] hashBucket) {
    list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs = [];
    for(hash <- hashBucket) {
        if(size(hashBucket[hash]) < 2) {
            continue;
        }
        subtrees = hashBucket[hash];
        for(i <- [0..size(subtrees)-1]) {
            for(j <- [i+1..size(subtrees)]) {
                clonePairs += [<subtrees[i], subtrees[j]>];
            }
        }
    }
    

    clonePairs = deleteSubClonePairs(clonePairs);

    return clonePairs;
}
    

void main() {
    Declaration ast = createAstFromFile(|cwd:///projects/TestClone1/Clone1.java|, true);
    list[Declaration] asts = [ast];
    basicCloneDetection(asts);
}

// [1] I. D. Baxter, A. Yahin, L. Moura, M. Sant'Anna and L. Bier, "Clone detection using abstract syntax trees," Proceedings. International Conference on Software Maintenance (Cat. No. 98CB36272), Bethesda, MD, USA, 1998, pp. 368-377, doi: 10.1109/ICSM.1998.738528, https://ieeexplore.ieee.org/abstract/document/738528