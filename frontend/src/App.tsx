import { useState } from "react";
import * as d3 from "d3";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";
import LinePlot from "./LinePlot";

interface AppProps {
  data: number[];
  width?: number;
  height?: number;
  marginTop?: number;
  marginRight?: number;
  marginBottom?: number;
  marginLeft?: number;
}

export default function App() {
  const [data, setData] = useState(() => d3.ticks(-2, 2, 200).map(Math.sin));

  function onMouseMove(event: React.MouseEvent<HTMLDivElement, MouseEvent>) {
    const [x, y] = d3.pointer(event);
    setData(data.slice(-200).concat(Math.atan2(x, y)));
  }

  return (
    <div onMouseMove={onMouseMove}>
      <LinePlot data={data} />
    </div>
  );
}
