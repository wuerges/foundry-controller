import "./App.css";
import { useState, useEffect } from "react";

const CHECKING = "Checking";
const WORKING = "Working";
const CHECKED = "Checked";

function App() {
  const [status, setStatus] = useState(CHECKING);
  const [instanceInfo, setInstanceInfo] = useState({});

  const doStart = async () => {
    setStatus(WORKING);
    await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/start"
    );
    setStatus(CHECKING);
  };
  const doStop = async () => {
    setStatus(WORKING);
    await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/stop"
    );
    setStatus(CHECKING);
  };
  const isChecking = () => {
    return status === CHECKING;
  };
  const isStopped = () =>
    !!(
      instanceInfo &&
      instanceInfo.instance_info &&
      instanceInfo.instance_info.state === "stopped"
    );

  useEffect(async () => {
    if (status !== CHECKING) return;

    const response = await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/check"
    );
    const data = await response.json();

    setInstanceInfo({
      instance_info: JSON.parse(data.instance_info),
      hosted_zone_info: JSON.parse(data.hosted_zone_info),
    });
    setStatus(CHECKED);
  }, [status]);

  return (
    <div className="App">
      <header className="App-header">Control the foundry server</header>
      <section
        className="App-content"
        style={{ width: "60vw", margin: "auto" }}
      >
        <pre style={{ textAlign: "left" }}>
          Status: {status} <br />
          Launch Time:
          {instanceInfo &&
            instanceInfo.instance_info &&
            instanceInfo.instance_info.launch_time}
          <br />
          IP:
          {instanceInfo &&
            instanceInfo.instance_info &&
            instanceInfo.instance_info.public_ip_address}
          <br />
          State:
          {instanceInfo &&
            instanceInfo.instance_info &&
            instanceInfo.instance_info.state}
        </pre>
      </section>
      <section className="App-content">
        <button disabled={status !== CHECKED || !isStopped()} onClick={doStart}>
          Start
        </button>
        <button disabled={status !== CHECKED || isStopped()} onClick={doStop}>
          Stop
        </button>
      </section>
    </div>
  );
}

export default App;
