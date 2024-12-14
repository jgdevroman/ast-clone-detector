import { useEffect, useState } from "react";
import * as d3 from "d3";
import "./App.css";
import LinePlot from "../components/LinePlot";
import Treemap from "../components/Treemap/Treemap";

const dataset = {
  children: [
    {
      name: "boss1",
      children: [
        { name: "mister_a", group: "A", value: 28, colname: "level3" },
        { name: "mister_b", group: "A", value: 19, colname: "level3" },
        { name: "mister_c", group: "C", value: 18, colname: "level3" },
        { name: "mister_d", group: "C", value: 19, colname: "level3" },
      ],
      colname: "level2",
    },
    {
      name: "boss2",
      children: [
        { name: "mister_e", group: "C", value: 14, colname: "level3" },
        { name: "mister_f", group: "A", value: 11, colname: "level3" },
        { name: "mister_g", group: "B", value: 15, colname: "level3" },
        { name: "mister_h", group: "B", value: 16, colname: "level3" },
      ],
      colname: "level2",
    },
    {
      name: "boss3",
      children: [
        { name: "mister_i", group: "B", value: 10, colname: "level3" },
        { name: "mister_j", group: "A", value: 13, colname: "level3" },
        { name: "mister_k", group: "A", value: 13, colname: "level3" },
        { name: "mister_l", group: "D", value: 25, colname: "level3" },
        { name: "mister_m", group: "D", value: 16, colname: "level3" },
        { name: "mister_n", group: "D", value: 28, colname: "level3" },
      ],
      colname: "level2",
    },
  ],
  name: "CEO",
};
export default function App() {
  const [data, setData] = useState<typeof dataset | null>(null);

  useEffect(() => {
    setData(dataset);
  }, []);

  function deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj));
  }

  const updateData1 = () => {
    var _data = deepCopy(data);

    _data["children"][0]["children"][0]["value"] = 50;
    _data["children"][0]["children"][1]["value"] = 10;
    _data["children"][0]["children"][2]["value"] = 30;

    _data["children"][1]["children"][0]["value"] = 4;
    _data["children"][1]["children"][1]["value"] = 8;

    setData(_data);
  };

  const updateData2 = () => {
    var _data = deepCopy(data);

    _data["children"][0]["children"].push({
      name: "mister_p",
      group: "C",
      value: 20,
      colname: "level3",
    });

    _data["children"][2]["children"].splice(2, 1);

    setData(_data);
  };

  const updateData3 = () => {
    var _data = deepCopy(data);

    _data["children"].push({
      name: "boss4",
      children: [
        {
          name: "mister_z",
          group: "E",
          value: 40,
          colname: "level3",
        },
      ],
    });

    setData(_data);
  };

  const updateData4 = () => {
    var _data = deepCopy(data);

    _data["children"].splice(1, 1);

    setData(_data);
  };

  const resetData = () => {
    setData(dataset);
  };

  if (data === null) return <></>;

  return (
    <div>
      <Treemap data={data} />
    </div>
  );
}
