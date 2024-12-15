import { useEffect, useState } from "react";
import "./Home.css";
import Treemap from "../components/Treemap/Treemap";
import treemapData from "../../../results/smallsql0.21_src/Treemap.json";
import CirclePack from "../components/CirclePack/CirclePack";

export default function App() {
  const dataset = treemapData;

  const [data, setData] = useState<typeof dataset | null>(null);
  const [highlighted, setHighlighted] = useState<string | null>(null);

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
