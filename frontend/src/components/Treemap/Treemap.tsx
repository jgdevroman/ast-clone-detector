// Treemap.js
import * as d3 from "d3";
import { useRef, useEffect } from "react";

const path = ["src", "components", "Button", "index.java"];

const dataset = {
  name: "src",
  children: [
    {
      name: "components",
      children: [
        {
          name: "Button",
          children: [
            { name: "index.java", value: 10 },
            { name: "Button.java", value: 10 },
            { name: "hooks.java", value: 8 },
          ],
        },
        { name: "mister_b", value: 19 },
        {
          name: "mister_c",
          children: [
            { name: "mister_q", value: 10 },
            { name: "mister_r", value: 10 },
            { name: "mister_s", value: 30 },
            {
              name: "mister_t",
              children: [
                { name: "mister_u", value: 10 },
                { name: "mister_v", value: 10 },
                { name: "mister_w", value: 8 },
                { name: "mister_x", value: 40 },
              ],
            },
          ],
        },
        { name: "mister_d", value: 19 },
      ],
    },
    {
      name: "boss2",
      children: [
        { name: "mister_e", value: 14 },
        { name: "mister_f", value: 11 },
        { name: "mister_g", value: 15 },
        { name: "mister_h", value: 16 },
      ],
    },
    {
      name: "boss3",
      children: [
        { name: "mister_i", value: 10 },
        { name: "mister_j", value: 13 },
        { name: "mister_k", value: 13 },
        { name: "mister_l", value: 25 },
        { name: "mister_m", value: 16 },
        { name: "mister_n", value: 28 },
      ],
    },
  ],
};

const generateUniqueID = (prefix?: string) => {
  return prefix + "_" + Math.random().toString(36);
};

interface TreemapProps {
  width?: number;
  height?: number;
  data?: any; // Replace 'any' with a more specific type if possible
}

function Treemap({ width, height, data = dataset }: TreemapProps) {
  const ref = useRef<SVGSVGElement>(null);
  const mapWidth = width ? width : window.innerWidth - 100;
  const mapHeight = height ? height : window.innerHeight - 100;

  useEffect(() => {
    draw();
  }, [data]);

  const draw = () => {
    const svg = d3
      .select(ref.current)
      .attr("width", mapWidth)
      .attr("height", mapHeight)
      .attr("style", "max-width: 100%; height: auto; font: 10px sans-serif;");

    // Give the data to this cluster layout:
    var root = d3
      .hierarchy(data)
      .sum((d) => d.value)
      .sort((a, b) => b.value - a.value);

    // initialize treemap
    d3
      .treemap()
      .size([mapWidth, mapHeight])
      .paddingTop(28)
      .paddingRight(7)
      .paddingInner(3)(root);

    const color = d3.scaleOrdinal(
      data.children.map((d: any) => d.name),
      d3.schemeTableau10
    );

    const opacity = d3.scaleLinear().domain([10, 30]).range([0.5, 1]);

    // Select the nodes
    var nodes = svg
      .selectAll("g")
      .data(root.leaves())
      .join("g")
      .attr("transform", (d) => `translate(${d.x0},${d.y0})`);

    // Append a tooltip.
    const format = d3.format(",d");
    nodes.append("title").text(
      (d) =>
        `${d
          .ancestors()
          .reverse()
          .map((d) => d.data.name)
          .join(".")}\n${format(d.value)}`
    );

    // draw rectangles
    nodes
      .append("rect")
      .attr("id", (d) => (d.leafUid = generateUniqueID("leaf")))
      .attr("fill", (d) => {
        while (d.depth > 1) d = d.parent;
        return color(d.data.name);
      })
      .attr("width", (d) => d.x1 - d.x0)
      .attr("height", (d) => d.y1 - d.y0)
      .style("opacity", function (d) {
        return opacity(d.data.value);
      });

    nodes
      .append("clipPath")
      .attr("id", (d) => (d.clipUid = generateUniqueID("clip")))
      .append("use")
      .attr("xlink:href", (d) => d.leafUid.href);

    // select node titles
    var nodeText = svg.selectAll("text").data(root.leaves());

    // add the text
    nodeText
      .enter()
      .append("text")
      .attr("x", function (d: any) {
        return d.x0 + 5;
      }) // +10 to adjust position (more right)
      .attr("y", function (d: any) {
        return d.y0 + 20;
      }) // +20 to adjust position (lower)
      // .text(function (d: any) {
      //   return d.data.name.replace("mister_", "");
      // })
      .attr("font-size", "19px")
      .attr("fill", "white");

    // select node titles
    var nodeVals = svg.selectAll("vals").data(root.leaves());

    // add the values
    nodeVals
      .enter()
      .append("text")
      .attr("x", function (d: any) {
        return d.x0 + 5;
      }) // +10 to adjust position (more right)
      .attr("y", function (d: any) {
        return d.y0 + 35;
      }) // +20 to adjust position (lower)
      .text(function (d: any) {
        return d.data.value;
      })
      .attr("font-size", "11px")
      .attr("fill", "white");

    // add the parent node titles
    svg
      .selectAll("titles")
      .data(
        root.descendants().filter(function (d) {
          return d.depth == 1;
        })
      )
      .enter()
      .append("text")
      .attr("x", function (d: any) {
        return d.x0;
      })
      .attr("y", function (d: any) {
        return d.y0 + 21;
      })
      .text(function (d) {
        return d.data.name;
      })
      .attr("font-size", "19px")
      .attr("fill", function (d: any) {
        return color(d.data.name) as string;
      });

    // chart heading
    svg
      .append("text")
      .attr("x", 0)
      .attr("y", 14) // +20 to adjust position (lower)
      .text(root.data.name)
      .attr("font-size", "19px")
      .attr("fill", "grey");
  };

  return (
    <div className="chart">
      <svg ref={ref}></svg>
    </div>
  );
}

export default Treemap;
