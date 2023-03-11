const { Elm } = require("../app/EasyRacer");
const { GenericContainer, AlwaysPullPolicy } = require("testcontainers");

describe("EasyRacer", () => {
  let container;
  let easyRacer;

  beforeAll(async () => {
    container = await new GenericContainer("ghcr.io/jamesward/easyracer")
      .withExposedPorts(8080)
      .withPullPolicy(new AlwaysPullPolicy())
      .start();

    easyRacer = Elm.EasyRacer.init({
      "host": container.getHost(),
      "portNumber": container.getMappedPort(8080)
    });
    easyRacer.runScenario = function(scenarioNumber) {
      this.ports.nextScenario.send(scenarioNumber);
      return new Promise((resolve) => {
        let handle = function(scenarioResult) {
          resolve(scenarioResult);
          this.ports.sendResult.unsubscribe(handle);
        }
        this.ports.sendResult.subscribe(handle);
      });
    };
  }, 300_000);

  afterAll(async () => {
    await container.stop();
  });

  it("scenario 0", async () => {
    expect(await easyRacer.runScenario(0)).toBe("");
  });
});
