// Treemap.js
import * as d3 from "d3";
import { useRef, useEffect } from "react";

interface TreemapProps {
  width?: number;
  height?: number;
  data: any; // Replace 'any' with a more specific type if possible
}

function Treemap({ width, height, data }: TreemapProps) {
  const ref = useRef<SVGSVGElement>(null);
  const mapWidth = width ? width : window.innerWidth - 100;
  const mapHeight = height ? height : window.innerHeight - 100;
  useEffect(() => {
    const svg = d3
      .select(ref.current)
      .attr("width", mapWidth)
      .attr("height", mapHeight)
      .style("border", "1px solid black");
  }, []);

  useEffect(() => {
    draw();
  }, [data]);

  const draw = () => {
    const svg = d3.select(ref.current);

    // Give the data to this cluster layout:
    var root = d3.hierarchy(data).sum(function (d) {
      return d.value;
    });

    // initialize treemap
    d3
      .treemap()
      .size([mapWidth, mapHeight])
      .paddingTop(28)
      .paddingRight(7)
      .paddingInner(3)(root);

    const color = d3
      .scaleOrdinal()
      .domain(["boss1", "boss2", "boss3"])
      .range(["#402D54", "#D18975", "#8FD175"]);

    const opacity = d3.scaleLinear().domain([10, 30]).range([0.5, 1]);

    // Select the nodes
    var nodes = svg.selectAll("rect").data(root.leaves());

    // draw rectangles
    nodes
      .enter()
      .append("rect")
      .attr("x", function (d: any) {
        return d.x0;
      })
      .attr("y", function (d: any) {
        return d.y0;
      })
      .attr("width", function (d: any) {
        return d.x1 - d.x0;
      })
      .attr("height", function (d: any) {
        return d.y1 - d.y0;
      })
      .style("stroke", "black")
      .style("fill", function (d: any): string {
        return color(d.parent.data.name) as string;
      })
      .style("opacity", function (d) {
        return opacity(d.data.value);
      });

    nodes.exit().remove();

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
      .text(function (d: any) {
        return d.data.name.replace("mister_", "");
      })
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

    // Add the chart heading
    svg
      .append("text")
      .attr("x", 0)
      .attr("y", 14) // +20 to adjust position (lower)
      .text("Three group leaders and 14 employees")
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
