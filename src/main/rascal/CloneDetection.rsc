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

int MASS_THRESHOLD = 1500;

// Compute the mass of a given AST
int getMass(node subtree) {
    return size(toString(subtree));
}

void basicCloneDetection(list[Declaration] asts, int threshold = MASS_THRESHOLD, bool type2 = true) {
    map[str, list[tuple[node, loc]]] hashBucket = ();    
    for(ast <- asts) {
        // For type2 clones
        if (type2) {
            ast = bottom-up visit(ast) {
                // case \methodCall(list[Type] typeArguments, Expression name, list[Expression] arguments): continue;
                // case \methodCall(Expression receiver, list[Type] typeArguments, Expression name, list[Expression] arguments): continue;
                case Declaration declaration: {
                    newDeclaration = visit(declaration) {
                        case id(_): {
                            // println([l | /l:id(s) <- ast]);
                            // println("Declaration: <declaration>");
                            insert id("", src=ast.src);
                        } 
                    }
                    insert newDeclaration;
                }
            }
        }

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

    map[str, list[tuple[node, loc]]] type1Clones = ();
    for(hash <- hashBucket) {
        if(size(hashBucket[hash]) > 1) {
            type1Clones[hash] = hashBucket[hash];
        }
    }

    list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs = createClonePairs(type1Clones);

    for (clonePair <- clonePairs) {
        println("Clone pair: <clonePair[0][1]> and <clonePair[1][1]> with mass <getMass(clonePair[0][0])>");
        nodeString = toString(unsetRec(clonePair[0][0]));
        // println("Test: <nodeString>");
        // println("Annotations: <getAnnotations(clonePair[0][0])>");
        // println("Test: <clonePair[0][0]>");
        // // regex that matches "id(%s)"
        // if((/variable\(id\((.*)\)\)/ := nodeString)) {
        //     replace "id(%s)" with "id()"
        //     nodeString = replaceAll(nodeString, /variable\(id\((.*)\)\)/, "variable(id())");
        // }
    }
    println(size(clonePairs));
}

bool isSubClone(tuple[tuple[node, loc], tuple[node, loc]] subClonePair, list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs) {
    for (clonePair <- clonePairs) {
        if(isStrictlyContainedIn(subClonePair[0][1], clonePair[0][1]) && isStrictlyContainedIn(subClonePair[1][1], clonePair[1][1])) {
            // println("subtree <subClonePair[0][1]> and <subClonePair[1][1]> is a subclone of <clonePair[0][1]> and <clonePair[1][1]>");
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
    list[Declaration] asts = getASTs(|cwd:///projects/TestClone1/|);
    basicCloneDetection(asts);
}

// [1] I. D. Baxter, A. Yahin, L. Moura, M. Sant'Anna and L. Bier, "Clone detection using abstract syntax trees," Proceedings. International Conference on Software Maintenance (Cat. No. 98CB36272), Bethesda, MD, USA, 1998, pp. 368-377, doi: 10.1109/ICSM.1998.738528, https://ieeexplore.ieee.org/abstract/document/738528