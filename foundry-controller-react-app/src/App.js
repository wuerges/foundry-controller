import "./App.css";
import { useState, useEffect } from "react";

const CHECKING = "Checking";
const CHECKED = "Checked";

function App() {
  const [status, setStatus] = useState(CHECKING);
  const [instanceInfo, setInstanceInfo] = useState({});

  const doStart = async () => {
    await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/start"
    );
  };
  const doStop = async () => {
    await fetch(
      "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/stop"
    );
  };
  const isStopped = () =>
    !!(
      instanceInfo &&
      instanceInfo.instance_info &&
      instanceInfo.instance_info.state === "stopped"
    );

  useEffect(() => {
    const timer = setInterval(async () => {
      setStatus(CHECKING);

      const response = await fetch(
        "https://enj5pwv63b.execute-api.sa-east-1.amazonaws.com/Prod/check"
      );
      const data = await response.json();

      // {"instance_info":"{\"launch_time\":\"2022-01-04 17:43:58 UTC\",\"ipv_6_address\":null,\"state\":\"stopped\"}","hosted_zone_info":"{\"record_name\":\"kapparpg.wu.dev.br\",\"record_data\":[\"18.231.4.124\"]}"}

      setInstanceInfo({
        instance_info: JSON.parse(data.instance_info),
        hosted_zone_info: JSON.parse(data.hosted_zone_info),
      });
      setStatus(CHECKED);
    }, 5000);
    return () => {
      clearInterval(timer);
    };
  });

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
        <button disabled={!isStopped()} onClick={doStart}>
          Start
        </button>
        <button disabled={isStopped()} onClick={doStop}>
          Stop
        </button>
      </section>
    </div>
  );
}

export default App;
