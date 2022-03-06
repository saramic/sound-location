<script>
  import { time } from "../lib/stores.js";
  import { formatTime } from "../lib/utils.js";

  let geoLocation = false;
  let geoWatch = false;

  let unsubscribe;
  let lapse = 0;
  let previous = 0;
  let lastLapse = 0;

  let error;
  let message;

  let accuracy;
  let altitude;
  let altitudeAccuracy;
  let heading;
  let latitude;
  let longitude;
  let speed;

  function clicked() {
    geoLocation = !geoLocation;
    if (geoLocation) {
      if (navigator.geolocation) {
        message = "getting geo location";
        navigator.geolocation.getCurrentPosition(setCurrentPosition, positionError, {
          enableHighAccuracy: false,
          timeout: 15000,
          maximumAge: 0
        });
      } else {
        error = "Geolocation is not supported by this browser.";
      }
    }
  }

  function setCurrentPosition(position) {
    terminate();
    lastLapse = lapse;

    accuracy = position.coords.accuracy;
    altitude = position.coords.altitude;
    altitudeAccuracy = position.coords.altitudeAccuracy;
    heading = position.coords.heading;
    latitude = position.coords.latitude;
    longitude = position.coords.longitude;
    speed = position.coords.speed;

    unsubscribe = time.subscribe((value) => {
      lapse = value + previous;
    });
  }

  function positionError(positionError) {
    switch (positionError.code) {
      case positionError.PERMISSION_DENIED:
        error = "User denied the request for Geolocation.";
        break;
      case positionError.POSITION_UNAVAILABLE:
        error = "Location information is unavailable.";
        break;
      case positionError.TIMEOUT:
        error = "The request to get user location timed out.";
        break;
      case positionError.UNKNOWN_ERROR:
        error = "An unknown error occurred.";
        break;
    }
    console.error(error);
  }

  function startWatch() {
    if (!geoWatch) {
      if ("geolocation" in navigator && "watchPosition" in navigator.geolocation) {
        message = "start geo watch";
        geoWatch = navigator.geolocation.watchPosition(setCurrentPosition, positionError, {
          enableHighAccuracy: false,
          timeout: 15000,
          maximumAge: 0
        });
      } else {
        error = "Geolocation is not supported by this browser.";
      }
    }
  }

  function stopWatch() {
    message = "start geo watch";
    navigator.geolocation.clearWatch(geoWatch);
    geoWatch = undefined;
  }

  function terminate() {
    if (unsubscribe) {
      unsubscribe();
      unsubscribe = null;
    }
  }
</script>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://kit.svelte.dev">kit.svelte.dev</a> to read the documentation</p>

{#if message}
  <div>
    {message}
  </div>
{/if}
{#if error}
  <div>
    {error}
  </div>
{/if}

<strong>Get location</strong>
<button on:click={clicked}>
  {geoLocation ? "Stop" : "Play"}
</button>

<strong>Watch location</strong>
<button on:click={geoWatch ? stopWatch : startWatch}>
  {geoWatch ? "Stop" : "Play"}
</button>

<dl>
  <dt>last updated (milliseconds) ago</dt>
  <dd>{formatTime(lapse)}</dd>
  <dt>Duration between updates</dt>
  <dd>{formatTime(lastLapse)}</dd>
  <dt>accuracy</dt>
  <dd>{accuracy}</dd>
  <dt>altitude</dt>
  <dd>{altitude}</dd>
  <dt>altitude accuracy</dt>
  <dd>{altitudeAccuracy}</dd>
  <dt>heading</dt>
  <dd>{heading}</dd>
  <dt>latitude</dt>
  <dd>{latitude}</dd>
  <dt>longitude</dt>
  <dd>{longitude}</dd>
  <dt>speed</dt>
  <dd>{speed}</dd>
</dl>
