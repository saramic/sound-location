<script>
  import { time } from "../lib/stores.js";
  import { formatTime } from "../lib/utils.js";
  import Canvas from "../lib/Canvas.svelte";
  import Point from "../lib/Point.svelte";

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

  let wayPoints = [
    { latitude: -37.783406, longitude: 144.996296 },
    { latitude: -37.783571, longitude: 144.996078 },
    { latitude: -37.783571, longitude: 144.996296 },
    { latitude: -37.783406, longitude: 144.996078 }
  ];
  const canvasHeight = 400;
  const canvasWidth = 200;

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

  function calculateRatio() {
    // TODO: only needs to be calculated when a new point outside of bounds is added
    const maxLng = Math.max(...wayPoints.map((wayPoint) => wayPoint.longitude));
    const minLng = Math.min(...wayPoints.map((wayPoint) => wayPoint.longitude));
    const wRatio = canvasWidth / Math.max(Math.abs(maxLng - minLng), 0.00005);
    const maxLat = Math.max(...wayPoints.map((wayPoint) => wayPoint.latitude));
    const minLat = Math.min(...wayPoints.map((wayPoint) => wayPoint.latitude));
    const hRatio = canvasHeight / Math.max(Math.abs(maxLat - minLat), 0.00005);
    return Math.min(wRatio, hRatio);
  }

  function xForWayPoint(wayPoint) {
    const ratio = calculateRatio();
    const minLng = Math.min(...wayPoints.map((wayPoint) => wayPoint.longitude));
    return (wayPoint.longitude - minLng) * ratio - canvasWidth / 2;
  }

  function yForWayPoint(wayPoint) {
    const ratio = calculateRatio();
    const maxLat = Math.max(...wayPoints.map((wayPoint) => wayPoint.latitude));
    return (maxLat - wayPoint.latitude) * ratio - canvasHeight / 2;
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

    console.log(wayPoints);
    wayPoints = [
      ...wayPoints,
      {
        latitude: latitude,
        longitude: longitude
      }
    ];
    console.log(wayPoints);

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
        unsubscribe = time.subscribe((value) => {
          lapse = value + previous;
        });
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

<Canvas height={canvasHeight} width={canvasWidth}>
  {#each wayPoints as wayPoint}
    <Point x={xForWayPoint(wayPoint)} y={yForWayPoint(wayPoint)} />
  {/each}
</Canvas>
