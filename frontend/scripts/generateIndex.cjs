const fs = require("fs");
const path = require("path");

const directoryPath = path.join(__dirname, "../../results"); // Adjust the path as needed

function getAllJsonFiles(dirPath, arrayOfFiles) {
  const files = fs.readdirSync(dirPath);

  arrayOfFiles = arrayOfFiles || [];

  files.forEach((file) => {
    if (fs.statSync(path.join(dirPath, file)).isDirectory()) {
      arrayOfFiles = getAllJsonFiles(path.join(dirPath, file), arrayOfFiles);
    } else if (file.endsWith(".json")) {
      arrayOfFiles.push(path.join(dirPath, file));
    }
  });

  return arrayOfFiles;
}

const jsonFiles = getAllJsonFiles(directoryPath);

const fileImports = [];
const fileExports = [];

jsonFiles.forEach((file) => {
  const relativePath = `.${file.replace(directoryPath, "")}`;
  const variableName = `${relativePath
    .split(["/"])
    .splice(1)
    .join("_")
    .replace(".json", "")
    .replaceAll(".", "")
    .replaceAll("-", "_")}`;
  fileImports.push(`import ${variableName} from '${relativePath}';`);
  fileExports.push(variableName);
});

const jsContent = `${fileImports.join(
  "\n"
)}\n\nconst result = { ${fileExports.join(", ")} };\n\nexport default result;`;

fs.writeFileSync(path.join(directoryPath, "index.ts"), jsContent);
console.log("index.js file has been generated.");
// fs.writeFileSync(path.join(directoryPath, "index.d.ts"), dtsContent);
// console.log("index.js and index.d.ts files have been generated.");
