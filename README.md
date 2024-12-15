# AST Based Clone Detection and Visualizer

Author: Roman Kornig @jgdevroman, Jakub Stanislaw Kaşıkcı @jskasikci

## How to use

### Clone Detection

1. Place the Java project folder into the `projects` folder
2. Make sure that the Java project has a `pom.xml` file in its root
3. Start a rascal terminal at the root and import `Main`
4. Run `main()` to run the analysis
5. The test results will be written into text files in the `report` directory

### Install and Run the Visualizer

1. Install npm and node.js if needed
   1. Download and install node.js from [here](https://nodejs.org/en/download/)
      1. Check if npm is installed by running `npm -v` in the terminal
      2. Check if node.js is installed by running `node -v` in the terminal
      3. If not installed, install npm by running `npm install npm@latest -g`
2. Install the required packages by running `npm install` in the `frontend` folder

```bash
   cd frontend
   npm install
```

3. Run the visualizer by running `npm start` in the `frontend` folder

```bash
   npm start
```

4. Open the browser and go to `localhost:5173`
5. Enjoy!
