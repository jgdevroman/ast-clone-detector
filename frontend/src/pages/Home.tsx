import { useEffect, useState } from "react";
import "./Home.css";
import Treemap from "../components/Treemap/Treemap";
import treemapData from "../../../results/smallsql0.21_src/Treemap.json";

export default function App() {
  const dataset = treemapData;

  const [data, setData] = useState<typeof dataset | null>(null);

  useEffect(() => {
    setData(dataset);
  }, []);

  if (data === null) return <></>;

  return (
    <div>
      <Treemap data={data} />
    </div>
  );
}
