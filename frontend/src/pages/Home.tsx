import { useEffect, useState } from "react";
import "./Home.css";
import treemapData from "../../../results/smallsql0.21_src/Treemap.json";
import results from "../../../results/";
import CirclePack from "../components/CirclePack/CirclePack";

export default function App() {
  const dataset = treemapData;

  const [data, setData] = useState<typeof dataset | null>(null);
  const [highlighted, setHighlighted] = useState<string | null>(null);
  console.log("cloneData", results);
  const projects: Record<string, any> = {};

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

  console.log("projects", projects);

  useEffect(() => {
    setData(dataset);
  }, []);

  if (data === null) return <></>;

  return (
    <div>
      <CirclePack data={data} setHighlighted={setHighlighted} />
      <div>
        <p>highlighted: {highlighted}</p>
      </div>
    </div>
  );
}
