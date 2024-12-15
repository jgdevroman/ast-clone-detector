import * as d3 from "d3";
import { useRef, useEffect } from "react";

const generateUniqueID = (prefix?: string) => {
  return prefix + "_" + Math.random().toString(36);
};

interface CirclePackProps {
  width?: number;
  height?: number;
  data?: any; // Replace 'any' with a more specific type if possible
}

function calculateSize(size: number | undefined, maxSize: number) {
  if (size === undefined) {
    return maxSize;
  }

  return size > maxSize ? maxSize : size;
}

function CirclePack({ width, height, data }: CirclePackProps) {
  const ref = useRef<SVGSVGElement>(null);
  const mapHeight =  calculateSize(height, window.innerHeight - 100);
  const mapWidth = calculateSize(width, mapHeight);

  useEffect(() => {
    draw();
  }, [data]);

  const draw = () => {
    const color = d3
      .scaleLinear()
      .domain([0, 5])
      .range(["hsl(152,80%,80%)", "hsl(228,30%,40%)"])
      .interpolate(d3.interpolateHcl);

    // Compute the layout.
    const pack = (data) =>
      d3.pack().size([mapWidth, mapHeight]).padding(3)(
        d3
          .hierarchy(data)
          .sum((d) => d.value)
          .sort((a, b) => b.value - a.value)
      );
    const root = pack(data);

    // Create the SVG container.
    const svg = d3
      .select(ref.current)
      .attr(
        "viewBox",
        `-${mapWidth / 2} -${mapHeight / 2} ${mapWidth} ${mapHeight}`
      )
      .attr("width", mapWidth)
      .attr("height", mapHeight)
      .attr(
        "style",
        `max-width: 100%; height: auto; display: block; margin: 0 -14px; background: ${color(
          0
        )}; cursor: pointer;`
      );

    // Append the nodes.
    const node = svg
      .append("g")
      .selectAll("circle")
      .data(root.descendants().slice(1))
      .join("circle")
      .attr("fill", (d) => (d.children ? color(d.depth) : "white"))
      .attr("pointer-events", (d) => (!d.children ? "none" : null))
      .on("mouseover", function () {
        d3.select(this).attr("stroke", "#000");
      })
      .on("mouseout", function () {
        d3.select(this).attr("stroke", null);
      })
      .on(
        "click",
        (event, d) => focus !== d && (zoom(event, d), event.stopPropagation())
      );

    // Append the text labels.
    const label = svg
      .append("g")
      .style("font", "10px sans-serif")
      .attr("pointer-events", "none")
      .attr("text-anchor", "middle")
      .selectAll("text")
      .data(root.descendants())
      .join("text")
      .style("fill-opacity", (d) => (d.parent === root ? 1 : 0))
      .style("display", (d) => (d.parent === root ? "inline" : "none"))
      .text((d) => d.data.name);

    // Create the zoom behavior and zoom immediately in to the initial focus node.
    svg.on("click", (event) => zoom(event, root));
    let focus = root;
    let view;
    zoomTo([focus.x, focus.y, focus.r * 2]);

    function zoomTo(v) {
      const k = mapWidth / v[2];

      view = v;

      label.attr(
        "transform",
        (d) => `translate(${(d.x - v[0]) * k},${(d.y - v[1]) * k})`
      );
      node.attr(
        "transform",
        (d) => `translate(${(d.x - v[0]) * k},${(d.y - v[1]) * k})`
      );
      node.attr("r", (d) => d.r * k);
    }

    function zoom(event, d) {
      const focus0 = focus;

      focus = d;

      const transition = svg
        .transition()
        .duration(event.altKey ? 7500 : 750)
        .tween("zoom", (d) => {
          const i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2]);
          return (t) => zoomTo(i(t));
        });

      label
        .filter(function (d) {
          return d.parent === focus || this.style.display === "inline";
        })
        .transition(transition)
        .style("fill-opacity", (d) => (d.parent === focus ? 1 : 0))
        .on("start", function (d) {
          if (d.parent === focus) this.style.display = "inline";
        })
        .on("end", function (d) {
          if (d.parent !== focus) this.style.display = "none";
        });
    }
  };

  return (
    <div className="chart">
      <svg ref={ref}></svg>
    </div>
  );
}

export default CirclePack;
