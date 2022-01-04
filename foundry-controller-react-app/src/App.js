import "./App.css";
import { useState } from "react";

const STOPPED = "Stopped";
const CHECKING = "Checking";
const STARTED = "Started";

function App() {
  const [status, setStatus] = useState(CHECKING);
  const [instanceInfo, setInstanceInfo] = useState({});

  const checkStatus = async (e) => {
    switch (status) {
      case STOPPED: {
        setStatus(CHECKING);
        break;
      }
    }

    const response = await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/check"
    );
    const data = await response.json();

    setInstanceInfo(JSON.parse(data.ip_of_instance));

    console.log(data);
  };

  return (
    <div className="App">
      <header className="App-header">Control the foundry server</header>
      <section className="App-content">
        <button onClick={checkStatus} className={status}>
          {CHECKING}
        </button>
        <button>Start</button>
        <button>Stop</button>
      </section>
    </div>
  );
}

export default App;
