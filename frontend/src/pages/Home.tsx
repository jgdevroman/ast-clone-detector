import { useEffect, useState } from "react";
import "./Home.css";
import results from "../../../results/";
import CirclePack from "../components/CirclePack/CirclePack";
import "../output.css";
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
  filename: string;
  size: number;
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

  const initialTreemapData: string = getTreemapKey(
    selectedProject,
    selectedType
  );

  const [treemapData, setTreemapData] = useState<Record<string, any> | null>(
    results[initialTreemapData] || null
  );

  const [cloneData, setCloneData] = useState<CloneData[] | null>(null);

  const handleProjectChange = (e: any) => {
    setSelectedProject(e.target.value);
    const newTreeMapData = getTreemapKey(e.target.value, selectedType);
    setTreemapData(results[newTreeMapData]);
    // console.log("selectedProject", selectedProject);
  };

  const handleTypeChange = (e: any) => {
    setSelectedType(e.target.value);
    const newTreeMapData = getTreemapKey(selectedProject, e.target.value);
    setTreemapData(results[newTreeMapData]);
    // console.log("selectedType", selectedType);
  };

  useEffect(() => {
    console.log("selectedProject", selectedProject);
    console.log("selectedType", selectedType);
    setTreemapData(null);
    setTreemapData(treemapData);
  }, [treemapData, selectedProject, selectedType]);

  if (treemapData === null) return <></>;

  return (
    <div className="flex flex-row items-start">
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

      <div className="flex flex-col">
        <p>highlighted: {highlighted}</p>
      </div>
    </div>
  );
}
