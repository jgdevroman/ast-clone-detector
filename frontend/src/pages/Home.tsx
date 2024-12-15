import { useEffect, useState } from "react";
import "./Home.css";
import results from "../../../results/";
import CirclePack from "../components/CirclePack/CirclePack";
import "../output.css";
import * as d3 from "d3";

type Project = {
  title: string;
  key: string;
  type: string;
};

type TreemapData = {
  name?: string;
  children?: TreemapData[];
};

type CloneData = {
  src: string;
  path: string;
  file: string;
  length: number;
  type: string;
  beginLine: number;
  beginColumn: number;
  endLine: number;
  endColumn: number;
};

export default function App() {
  const [highlighted, setHighlighted] = useState<string | null>(null);
  // console.log("cloneData", results);
  const projects: { [key: string]: Project[] } = {};
  Object.keys(results).forEach((key) => {
    const title = key.split("_");
    const project = title[0];
    let type = title[title.length - 1];
    if (type !== "type1" && type !== "type2") {
      type = "type2";
    }

    if (!projects[project]) {
      projects[project] = [];
    }
    projects[project].push({
      title: project,
      key: key,
      type,
    });
  });
  // console.log("projects", projects);

  const projectOptions = Object.keys(projects);
  const typeOptions = ["type1", "type2"];

  const [selectedProject, setSelectedProject] = useState<string>(
    projectOptions[0]
  );
  const [selectedType, setSelectedType] = useState<string>(typeOptions[0]);

  const getTreemapKey = (project: string, type: string) => {
    return (
      projects[project].find(
        (project) => project.type === type && project.key.includes("Treemap")
      )?.key || ""
    );
  };

  const getClassKey = (project: string, type: string) => {
    return (
      projects[project].find(
        (project) => project.type === type && project.key.includes("Classes")
      )?.key || ""
    );
  };

  const initialTreemapData: string = getTreemapKey(
    selectedProject,
    selectedType
  );
  const initialClassData: string = getClassKey(selectedProject, selectedType);

  const [treemapData, setTreemapData] = useState<Record<string, any> | null>(
    results[initialTreemapData] || null
  );

  const [classData, setClassData] = useState<Record<string, any> | null>(
    results[initialClassData] || null
  );

  const [cloneClassData, setCloneClassData] = useState<
    Record<string, CloneData> | undefined
  >(undefined);

  const handleProjectChange = (e: any) => {
    setSelectedProject(e.target.value);
    d3.selectAll("svg > *").remove();
    const newTreeMapData = getTreemapKey(e.target.value, selectedType);
    setTreemapData(results[newTreeMapData]);
    const newClassData = getClassKey(e.target.value, selectedType);
    setClassData(results[newClassData]);
    // console.log("selectedProject", selectedProject);
  };

  const handleTypeChange = (e: any) => {
    setSelectedType(e.target.value);
    d3.selectAll("svg > *").remove();
    const newTreeMapData = getTreemapKey(selectedProject, e.target.value);
    setTreemapData(results[newTreeMapData]);
    const newClassData = getClassKey(selectedProject, e.target.value);
    setClassData(results[newClassData]);
    // console.log("selectedType", selectedType);
  };

  const getCloneClassData = (hash: string) => {
    // console.log("hash", hash);
    Object.keys(classData).forEach((key, index) => {
      // console.log("classData", key);
      if (key == hash) {
        // console.log(Object.values(classData)[index])
        setCloneClassData(Object.values(classData)[index]);
      }
    });
  };

  // useEffect(() => {
  //   console.log("selectedProject", selectedProject);
  //   console.log("selectedType", selectedType);
  //   // d3.selectAll("svg > *").remove();
  //   setTreemapData(treemapData);
  //   setClassData(classData);
  // }, [treemapData, selectedProject, selectedType, classData]);

  useEffect(() => {
    if (highlighted !== null && classData) {
      console.log("highlighted", highlighted);
      getCloneClassData(highlighted);
      console.log("newCloneClassData", cloneClassData);
    }
  }, [highlighted, classData, getCloneClassData]);

  if (treemapData === null) return <></>;

  return (
    <div className="flex flex-row items-start max-w-full max-h-screen">
      <div className="flex flex-col space-y-4">
        <div className="flex flex-row space-x-8 justify-center">
          <select onChange={(e) => handleProjectChange(e)}>
            {projectOptions.map((project) => (
              <option key={project} value={project}>
                {project}
              </option>
            ))}
          </select>
          <select onChange={(e) => handleTypeChange(e)}>
            {typeOptions.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
        </div>
        <CirclePack data={treemapData} setHighlighted={setHighlighted} />
      </div>

      <div className="flex flex-col justify-start text-left overflow-y-auto max-h-content">
        {cloneClassData && (
          <div className="space-y-8">
            {Object.keys(cloneClassData).map((key, index) => {
              return (
                <div key={index}>
                  <h2 className="font-semibold ">{cloneClassData[key].path}</h2>
                  <p>name: {cloneClassData[key].file}</p>
                  <p>length: {cloneClassData[key].length}</p>
                  <p>LOC: {`${cloneClassData[key].endLine - cloneClassData[key].beginLine}`}</p>
                  <p>
                    begin:
                    {`${cloneClassData[key].beginLine}, ${cloneClassData[key].beginColumn}`}
                  </p>
                  <p>
                    end:
                    {`${cloneClassData[key].endLine}, ${cloneClassData[key].endColumn}`}
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
