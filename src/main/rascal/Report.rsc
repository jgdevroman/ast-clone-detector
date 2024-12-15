module Report

import IO;
import Map;
import Node;
import List;
import String;
import Location;

void createReport(str projectName, int totalLOC, map[str, list[tuple[node, loc]]] type1CloneClasses, map[str, list[tuple[node, loc]]] type2CloneClasses) {
    int massThreshold = 50;

    tuple[int totalClones, int totalLines, int biggestClone, str biggestCloneLocation, list[str] examples] 
    processCloneClasses(map[str, list[tuple[node, loc]]] cloneClasses) {
        int totalClones = 0;
        int totalDuplicatedLines = 0;
        int biggestClone = 0;
        str biggestCloneLocation = "";
        list[str] exampleClones = [];

        for (cloneClassHash <- cloneClasses) {
            list[tuple[node, loc]] cloneClass = cloneClasses[cloneClassHash];
            totalClones += size(cloneClass);

            for (clone <- cloneClass) {
                loc l = clone[1];
                int length = l.end.line - l.begin.line + 1;
                totalDuplicatedLines += length;

                if (length > biggestClone) {
                    biggestClone = length;
                    biggestCloneLocation = "<l.file>: lines <l.begin.line> - <l.end.line> (<length> LOC)";
                }

                if (size(exampleClones) < 3) {
                    exampleClones += "<l.file>: lines <l.begin.line> - <l.end.line> (<length> LOC)";
                }
            }
        }
        return <totalClones, totalDuplicatedLines, biggestClone, biggestCloneLocation, exampleClones>;
    }

    tuple[int, int, int, str, list[str]] type1Stats = processCloneClasses(type1CloneClasses);
    tuple[int, int, int, str, list[str]] type2Stats = processCloneClasses(type2CloneClasses);

    real percentDuplicatedType1 = (type1Stats[1] * 100.0) / totalLOC;
    real percentDuplicatedType2 = (type2Stats[1] * 100.0) / totalLOC;

    str reportContent = "Clone Detection Report for Project: <projectName>\n
        -----------------------------------------
        Total Lines of Code (LOC): <totalLOC>
        Mass Threshold for Clones: <massThreshold>

Type 1 Clones:
        -----------------------------------------
        Total Clone Classes: <size(type1CloneClasses)>
        Total Clones: <type1Stats[0]>
        Total Duplicated Lines: <type1Stats[1]>
        Percentage of Duplicated Lines: <percentDuplicatedType1>%
        Biggest Clone (in LOC): <type1Stats[2]>
        Location: <type1Stats[3]>
        Example Clones:";

    for (str example <- type1Stats[4]) {
        reportContent += "  - <example>\n";
    }

    reportContent += "\nType 2 Clones:
        -----------------------------------------
        Total Clone Classes: <size(type2CloneClasses)>
        Total Clones: <type2Stats[0]>
        Total Duplicated Lines: <type2Stats[1]>
        Percentage of Duplicated Lines: <percentDuplicatedType2>%
        Biggest Clone (in LOC): <type2Stats[2]>
        Location: <type2Stats[3]>
        Example Clones:";

    for (str example <- type2Stats[4]) {
        reportContent += "  - <example>\n";
    }

    loc reportFile = |cwd:///report/<projectName>_Report.txt|;
    writeFile(reportFile, reportContent);
}
