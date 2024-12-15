import * as d3 from "d3";
import { useRef, useEffect, useState } from "react";
import "./CirclePack.css";

const generateUniqueID = (prefix?: string) => {
  return prefix + "_" + Math.random().toString(36);
};

const calculateFontSize = (size: number) => {
  const maxSize = 35;
  const minSize = 11;
  if (size > maxSize) {
    return maxSize;
  }
  if (size < minSize) {
    return minSize;
  }

  return size;
};

// Compute a random color hex from a given hash
const generateRandomColor = (hash: string) => {
  let color = "#";
  for (let i = 0; i < 3; i++) {
    const value = parseInt(hash.substring(i * 2, i * 2 + 2), 16);
    const adjustedValue = Math.max(value, 100); // Ensure the color is not too dark
    color += adjustedValue.toString(16).padStart(2, "0");
  }
  return color;
};

interface CirclePackProps {
  width?: number;
  height?: number;
  data?: any; // Replace 'any' with a more specific type if possible
  setHighlighted: (highlighted: string | null) => void;
}

function calculateSize(size: number | undefined, maxSize: number) {
  if (size === undefined) {
    return maxSize;
  }

  return size > maxSize ? maxSize : size;
}

function CirclePack({ width, height, data, setHighlighted }: CirclePackProps) {
  const ref = useRef<SVGSVGElement>(null);
  const mapHeight = calculateSize(height, window.innerHeight - 100);
  const mapWidth = calculateSize(width, mapHeight);
  //   const [highlighted, setHighlighted] = useState<string | null>(null);

  useEffect(() => {
    draw();
  }, [data]);

  const draw = () => {
    let highlighted: string | null = null;
    const depthColor = d3
      .scaleLinear()
      .domain([0, 6])
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
        `max-width: 100%; height: auto; display: block; margin: 0 -14px; background: ${depthColor(
          0
        )}; cursor: pointer;`
      );

    // Append the nodes.
    const node = svg
      .append("g")
      .selectAll("circle")
      .data(root.descendants().slice(1))
      .join("circle")
      .attr("fill", (d) => {
        if (!d.children) {
          return generateRandomColor(d.data.cloneClassHash);
        }
        return depthColor(d.depth);
      })
      .attr("className", (d) => {
        if (highlighted !== null && d.data.cloneClassHash === highlighted) {
          return "highlighted";
        }
      })
      .on("mouseover", function () {
        d3.select(this).attr("stroke", "#000");
      })
      .on("mouseout", function (event, d) {
        if (highlighted !== null && highlighted === d.data.cloneClassHash) {
          d3.select(this).attr("stroke", "red").attr("stroke-width", 5);
        } else {
          d3.select(this).attr("stroke", null);
        }
      })
      .on("click", function (event, d) {
        if (!d.data.children) {
          const cloneClassHash = !d.data.children
            ? d.data.cloneClassHash
            : null;
          highlighted = cloneClassHash;
          setHighlighted(cloneClassHash);
          console.log(highlighted);
          zoom(event, root);
          d3.selectAll("circle")
            .attr("stroke", (d) => {
              if (
                highlighted !== null &&
                d.data.cloneClassHash === highlighted
              ) {
                return "red";
              }
              return null;
            })
            .attr("stroke-width", (d) => {
              if (
                highlighted !== null &&
                d.data.cloneClassHash === highlighted
              ) {
                return 5;
              }
              return null;
            });
          return;
        }

        if (focus !== d) {
          zoom(event, d);
          event.stopPropagation();
        }
      });

    // Append the text labels.
    const label = svg
      .append("g")
      .attr("pointer-events", "none")
      .attr("text-anchor", "middle")
      .selectAll("text")
      .data(root.descendants())
      .join("text")
      .style("fill-opacity", (d) => {
        return d.parent === root ? 1 : 0;
      })
      .style("display", (d) => {
        return d.parent === root ? "inline" : "none";
      })
      .style("font-size", (d) => `${calculateFontSize(d.r)}px`)
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
