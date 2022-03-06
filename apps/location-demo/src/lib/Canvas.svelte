<script>
  import { onMount, setContext } from "svelte";
  let canvas;
  export let height;
  export let width;

  const drawFunctions = [];

  setContext("canvas", {
    register(drawFn) {
      drawFunctions.push(drawFn);
    },
    unregister(drawFn) {
      drawFunctions.splice(drawFunctions.indexOf(drawFn), 1);
    }
  });

  onMount(() => {
    const ctx = canvas.getContext("2d");
    canvas.height = height;
    canvas.width = width;

    function update() {
      //
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.save();
      ctx.translate(canvas.width / 2, canvas.height / 2);
      drawFunctions.forEach((drawFn) => {
        drawFn(ctx);
      });

      ctx.restore();

      frameId = requestAnimationFrame(update);
    }

    let frameId = requestAnimationFrame(update);

    return () => {
      cancelAnimationFrame(frameId);
    };
  });
</script>

<canvas bind:this={canvas} />

<slot />
