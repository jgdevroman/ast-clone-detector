module CloneDetection

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Node;
import List;
import Map;
import String;
import Location;


import Utility;

// Detect type I and type II clones in a given project based on the clone detection algorithm from Baxter et al.[1]

int MASS_THRESHOLD = 1000;

void basicCloneDetection(list[Declaration] asts, int threshold = MASS_THRESHOLD, bool type2 = true) {
    map[str, list[tuple[node, loc]]] hashBucket = createHashBuckets(asts, threshold, type2); 

    println("Create clone classes..");

    map[str, list[tuple[node, loc]]] cloneClasses = createCloneClasses(hashBucket);

    if(type2) {
        println("Type 1 & 2 clones detected:");
    } else {
        println("Type 1 clones detected:");
    }

    for (cloneClass <- [cloneClasses[hash] | hash <- cloneClasses]) {
        println("Clone class: ");
        for (clone <- cloneClass) {
            println("<clone[1]> with mass <getMass(clone[0])>");
            // println("Test: <unsetRec(clone[0])>");
            // println("No unset: <clone[0]>");
            // println("Unset: <unsetRec(clone[0], {"src", "decl"})> \n");
        }
    }

    println("Number of clone classes: <size(cloneClasses)>");

}

map[str, list[tuple[node, loc]]] createHashBuckets(list[Declaration] asts, int threshold, bool type2) {
    map[str, list[tuple[node, loc]]] hashBucket = (); 
    println("Traverse ASTs and detect clones with mass bigger than <threshold>.");
    for(ast <- asts) {
        // For type2 clones
        if (type2) {
            ast = visit(ast) {
                case i:\id(_): {
                    insert id("", src=i.src);
                } 
                case n:\number(_): {
                    insert number("", src=n.src);
                }
                case b:\booleanLiteral(_): {
                    insert booleanLiteral("", src=b.src);
                }
                case s:\stringLiteral(_): {
                    insert stringLiteral("", src=s.src);
                }
                case c:\characterLiteral(_): {
                    insert characterLiteral("", src=c.src);
                }
                case t:\textBlock(_): {
                    insert textBlock("", src=t.src);
                }
            }
        }

        top-down visit(ast) {
            case node subtree: {
                int mass = getMass(subtree);
                if(mass > threshold) {
                    str subtreeHash = hash(unsetRec(subtree, {"src", "decl", "typ"}));
                    if(subtreeHash in hashBucket) {
                        hashBucket[subtreeHash] = hashBucket[subtreeHash] + [<subtree, subtree.src>];
                    } else {
                        hashBucket[subtreeHash] = [<subtree, subtree.src>];
                    }
                }
            }
        }
    }
    return hashBucket;
}

// Compute the mass of a given AST
int getMass(node subtree) {
    return size(toString(subtree));
}

map[str, list[tuple[node, loc]]] createCloneClasses(map[str, list[tuple[node, loc]]] hashBucket) {
    map[str, list[tuple[node, loc]]] cloneClasses = ();
    for(hash <- hashBucket) {
        if(size(hashBucket[hash]) < 2) {
            continue;
        }
        subtrees = hashBucket[hash];
        cloneClasses[hash] = subtrees;
    }
    println("Delete clone sub clone classes");
    cloneClasses = deleteSubCloneClasses(cloneClasses);
    return cloneClasses;
}

map[str, list[tuple[node, loc]]] deleteSubCloneClasses(map[str, list[tuple[node, loc]]] cloneClasses) {
    map[str, list[tuple[node, loc]]] newCloneClasses = cloneClasses;
    for (cloneClassHash <- cloneClasses) {
        cloneClass = cloneClasses[cloneClassHash];
        for (subCloneClassHash <- cloneClasses) {
            subCloneClass = cloneClasses[subCloneClassHash];
            if (size(cloneClass) <= size(subCloneClass) && cloneClass != subCloneClass) {
                for (i <- [0..size(cloneClass)]) {
                    if (isStrictlyContainedIn(cloneClass[i][1], subCloneClass[i][1])) {
                        // println("Clone class <cloneClass> is a subclone of <subCloneClass>");
                        newCloneClasses = delete(newCloneClasses, cloneClassHash);
                        cloneClass = subCloneClass;
                    }
                }
            }
        }
    }
    return newCloneClasses;
}
void main() {
    list[Declaration] asts = getASTs(|cwd:///projects/TestClone1/|);
    basicCloneDetection(asts);
}

// bool isSubClone(tuple[tuple[node, loc], tuple[node, loc]] subClonePair, list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs) {
//     for (clonePair <- clonePairs) {
//         if(isStrictlyContainedIn(subClonePair[0][1], clonePair[0][1]) && isStrictlyContainedIn(subClonePair[1][1], clonePair[1][1])) {
//             // println("subtree <subClonePair[0][1]> and <subClonePair[1][1]> is a subclone of <clonePair[0][1]> and <clonePair[1][1]>");
//             return true;
//         }
//     }
//     return false;
// }
// list[tuple[tuple[node, loc], tuple[node, loc]]] deleteSubClonePairs(list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs) {
//     list[tuple[tuple[node, loc], tuple[node, loc]]] newClonePairs = clonePairs;
//     for (clonePair <- clonePairs) {
//         if(isSubClone(clonePair, clonePairs)) {
//             newClonePairs = delete(clonePairs, indexOf(clonePairs, clonePair));
//             return deleteSubClonePairs(newClonePairs);
//         }
//     }
//     return newClonePairs;
// } 

// list[tuple[tuple[node, loc], tuple[node, loc]]] createClonePairs(map[str, list[tuple[node, loc]]] hashBucket) {
//     list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs = [];
//     for(hash <- hashBucket) {
//         if(size(hashBucket[hash]) < 2) {
//             continue;
//         }
//         subtrees = hashBucket[hash];
//         for(i <- [0..size(subtrees)-1]) {
//             for(j <- [i+1..size(subtrees)]) {
//                 clonePairs += [<subtrees[i], subtrees[j]>];
//             }
//         }
//     }
//     clonePairs = deleteSubClonePairs(clonePairs);
//     return clonePairs;
// }

// [1] I. D. Baxter, A. Yahin, L. Moura, M. Sant'Anna and L. Bier, "Clone detection using abstract syntax trees," Proceedings. International Conference on Software Maintenance (Cat. No. 98CB36272), Bethesda, MD, USA, 1998, pp. 368-377, doi: 10.1109/ICSM.1998.738528, https://ieeexplore.ieee.org/abstract/document/738528