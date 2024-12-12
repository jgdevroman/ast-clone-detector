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
                // case Declaration declaration: {
                //     newDeclaration = visit(declaration) {
                //         case id(_): {
                //             insert id("", src=ast.src);
                //         } 
                //     }
                //     insert newDeclaration;
                // }
                // case m:\method(_,_,_,name,_,_,_): {
                //     newExpression = visit(name) {
                //         case i:id(_): {
                //             insert id("", src=i.src);
                //         }
                //     }
                //     m.name = newExpression;
                //     insert m;
                // }
                // case c:\class(_,name,_,_,_,_): {
                //     newExpression = visit(name) {
                //         case i:id(_): {
                //             insert id("", src=i.src);
                //         }
                //     }
                //     c.name = newExpression;
                //     insert c;
                // }
                // case p:\parameter(_,_,name,_): {
                //     newExpression = visit(name) {
                //         case i:id(_): {
                //             insert id("", src=i.src);
                //         }
                //     }
                //     p.name = newExpression;
                //     insert p;
                // }
                // case v:\variable(_,_): {
                //     newVariable = visit(v) {
                //         case i:id(_): {
                //             insert id("", src=i.src);
                //         }
                //     }
                //     insert newVariable;
                // }
                // case v:\variable(_,_,_): {
                //     newVariable = visit(v) {
                //         case i:id(_): {
                //             insert id("", src=i.src);
                //         }
                //     }
                //     insert newVariable;
                // }
                // case m:\methodCall(_,_,_): {
                    // newExpression = visit(name) {
                    //     case i:id(_): {
                    //         insert id("", src=i.src);
                    //     }
                    // }
                    // m.name = newExpression;
                    // insert m;
                    // println("Unset src call: <unsetRec(m, {"src"})>");
                    // println("Unset all: <unsetRec(m)>");
                // }
            }
        }

        top-down visit(ast) {
            case node subtree: {
                int mass = getMass(subtree);
                // println(mass);
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

    // map[str, list[tuple[node, loc]]] clones = ();
    // for(hash <- hashBucket) {
    //     if(size(hashBucket[hash]) > 1) {
    //         clones[hash] = hashBucket[hash];
    //     }
    // }

    // list[tuple[tuple[node, loc], tuple[node, loc]]] clonePairs = createClonePairs(clones);

    // for (clonePair <- clonePairs) {
    //     println("Clone pair: <clonePair[0][1]> and <clonePair[1][1]> with mass <getMass(clonePair[0][0])>");
    //     nodeString = toString(unsetRec(clonePair[0][0]));
    // }
    // println("Number of clone pairs: <size(clonePairs)>");

    list[list[tuple[node, loc]]] cloneClasses = createCloneClasses(hashBucket);

    for (cloneClass <- cloneClasses) {
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

list[list[tuple[node, loc]]] createCloneClasses(map[str, list[tuple[node, loc]]] hashBucket) {
    list[list[tuple[node, loc]]] cloneClasses = [hashBucket[hash] | hash <- hashBucket, size(hashBucket[hash]) > 1];
    cloneClasses = deleteSubCloneClasses(cloneClasses);
    return cloneClasses;
}

list[list[tuple[node, loc]]] deleteSubCloneClasses(list[list[tuple[node, loc]]] cloneClasses) {
    list[list[tuple[node, loc]]] newCloneClasses = cloneClasses;
    for (cloneClass <- cloneClasses) {
        for (subCloneClass <- cloneClasses) {
            if (size(cloneClass) == size(subCloneClass)) {
                for (i <- [0..size(cloneClass)]) {
                    if (isStrictlyContainedIn(cloneClass[i][1], subCloneClass[i][1])) {
                        newCloneClasses = delete(cloneClasses, indexOf(cloneClasses, cloneClass));
                        return deleteSubCloneClasses(newCloneClasses);
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

// [1] I. D. Baxter, A. Yahin, L. Moura, M. Sant'Anna and L. Bier, "Clone detection using abstract syntax trees," Proceedings. International Conference on Software Maintenance (Cat. No. 98CB36272), Bethesda, MD, USA, 1998, pp. 368-377, doi: 10.1109/ICSM.1998.738528, https://ieeexplore.ieee.org/abstract/document/738528